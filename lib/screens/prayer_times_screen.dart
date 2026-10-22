import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_settings_model.dart';
import '../services/prayer_notification_service.dart';
import '../services/prayer_settings_service.dart';
import 'prayer_times_settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  PrayerSettings? _settings;
  DateTime _now = DateTime.now();
  Prayer _nextPrayer = Prayer.fajr;
  DateTime? _nextPrayerTime;
  Duration _timeUntilNext = Duration.zero;

  bool _isLoading = true;
  bool _isUsingManualLocation = false;
  bool _isRefreshingLocation = false;

  String _locationName = 'جاري تحديد الموقع...';
  String _countryName = '';
  String _cityName = '';

  Timer? _timer;

  static const String _manualLocationKey = 'prayer_manual_location';
  static const String _countryKey = 'prayer_country';
  static const String _cityKey = 'prayer_city';
  static const String _latitudeKey = 'prayer_latitude';
  static const String _longitudeKey = 'prayer_longitude';

  static const List<_PrayerLocation> _locations = [
    _PrayerLocation('الأردن', 'عمّان', 31.9539, 35.9106),
    _PrayerLocation('الأردن', 'إربد', 32.5556, 35.8500),
    _PrayerLocation('الأردن', 'الزرقاء', 32.0728, 36.0879),
    _PrayerLocation('السعودية', 'الرياض', 24.7136, 46.6753),
    _PrayerLocation('السعودية', 'جدة', 21.4858, 39.1925),
    _PrayerLocation('السعودية', 'مكة المكرمة', 21.3891, 39.8579),
    _PrayerLocation('السعودية', 'المدينة المنورة', 24.5247, 39.5692),
    _PrayerLocation('الإمارات', 'أبوظبي', 24.4539, 54.3773),
    _PrayerLocation('الإمارات', 'دبي', 25.2048, 55.2708),
    _PrayerLocation('الكويت', 'الكويت', 29.3759, 47.9774),
    _PrayerLocation('قطر', 'الدوحة', 25.2854, 51.5310),
    _PrayerLocation('البحرين', 'المنامة', 26.2285, 50.5860),
    _PrayerLocation('عُمان', 'مسقط', 23.5880, 58.3829),
    _PrayerLocation('مصر', 'القاهرة', 30.0444, 31.2357),
    _PrayerLocation('فلسطين', 'القدس', 31.7683, 35.2137),
    _PrayerLocation('فلسطين', 'غزة', 31.5017, 34.4668),
    _PrayerLocation('العراق', 'بغداد', 33.3152, 44.3661),
    _PrayerLocation('لبنان', 'بيروت', 33.8938, 35.5018),
    _PrayerLocation('سوريا', 'دمشق', 33.5138, 36.2765),
    _PrayerLocation('تركيا', 'إسطنبول', 41.0082, 28.9784),
    _PrayerLocation('المغرب', 'الرباط', 34.0209, -6.8416),
    _PrayerLocation('الجزائر', 'الجزائر', 36.7538, 3.0588),
    _PrayerLocation('تونس', 'تونس', 36.8065, 10.1815),
    _PrayerLocation('المملكة المتحدة', 'لندن', 51.5074, -0.1278),
    _PrayerLocation('الولايات المتحدة', 'نيويورك', 40.7128, -74.0060),
  ];

  @override
  void initState() {
    super.initState();
    _initPrayerTimes();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initPrayerTimes() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // الإعدادات الموحدة هي المصدر الأول في كل أجزاء التطبيق.
      final PrayerSettings? savedSettings =
          await PrayerSettingsService.loadPrayerSettings();

      if (savedSettings != null) {
        _settings = savedSettings;
        _isUsingManualLocation = true;
        _countryName = savedSettings.selectedCountry.label;
        _cityName = savedSettings.selectedCity.name;

        await _calculateForSettings(savedSettings);
        return;
      }

      // توافق مع البيانات القديمة قبل إنشاء إعدادات الصلاة الموحدة.
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final bool manual = prefs.getBool(_manualLocationKey) ?? false;

      if (manual) {
        final double? latitude = prefs.getDouble(_latitudeKey);
        final double? longitude = prefs.getDouble(_longitudeKey);

        if (latitude != null && longitude != null) {
          _isUsingManualLocation = true;
          _countryName = prefs.getString(_countryKey) ?? '';
          _cityName = prefs.getString(_cityKey) ?? '';
          await _calculateForCoordinates(
            latitude,
            longitude,
            locationLabel:
                _cityName.isEmpty ? _countryName : '$_cityName - $_countryName',
          );
          return;
        }
      }

      _isUsingManualLocation = false;
      _countryName = '';
      _cityName = '';
      await _loadGpsLocation();
    } catch (e, stackTrace) {
      debugPrint('Prayer times initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() {
        _locationName = 'تعذر تحديد الموقع';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGpsLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _locationName = 'خدمة الموقع غير مفعلة';
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _locationName = 'إذن الموقع مرفوض نهائيًا';
        _isLoading = false;
      });
      return;
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      setState(() {
        _locationName = 'تم رفض إذن الموقع';
        _isLoading = false;
      });
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await _calculateForCoordinates(
      position.latitude,
      position.longitude,
      locationLabel:
          'الموقع الحالي • ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
    );
  }

  Future<void> _calculateForCoordinates(
    double latitude,
    double longitude, {
    required String locationLabel,
  }) async {
    final Coordinates coordinates = Coordinates(latitude, longitude);

    final CalculationParameters params =
        PrayerSettingsService.getCalculationParameters(
            PrayerSettingsService.getDefaultSettings());

    final PrayerTimes prayerTimes = PrayerTimes.today(coordinates, params);

    _prayerTimes = prayerTimes;
    _now = DateTime.now();

    _calculateNextPrayer();

    if (!mounted) return;

    setState(() {
      _locationName = locationLabel;
      _isLoading = false;
    });

    try {
      await PrayerNotificationService.checkAndUpdateIfNeeded();
    } catch (e, stackTrace) {
      debugPrint('Prayer notification update failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _calculateForSettings(PrayerSettings settings) async {
    final PrayerTimes prayerTimes =
        PrayerSettingsService.calculatePrayerTimes(settings);

    _prayerTimes = prayerTimes;
    _now = DateTime.now();
    _calculateNextPrayer();

    if (!mounted) return;

    setState(() {
      _locationName =
          '${settings.selectedCity.name} - ${settings.selectedCountry.label}';
      _isLoading = false;
    });

    try {
      await PrayerNotificationService.checkAndUpdateIfNeeded();
    } catch (e, stackTrace) {
      debugPrint('Prayer notification update failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _calculateNextPrayer() {
    final PrayerTimes? prayerTimes = _prayerTimes;
    if (prayerTimes == null) return;

    final DateTime now = DateTime.now();
    final List<_PrayerTime> prayers = [
      _PrayerTime(Prayer.fajr, prayerTimes.fajr),
      _PrayerTime(Prayer.dhuhr, prayerTimes.dhuhr),
      _PrayerTime(Prayer.asr, prayerTimes.asr),
      _PrayerTime(Prayer.maghrib, prayerTimes.maghrib),
      _PrayerTime(Prayer.isha, prayerTimes.isha),
    ];

    for (final _PrayerTime item in prayers) {
      if (item.time.isAfter(now)) {
        _nextPrayer = item.prayer;
        _nextPrayerTime = item.time;
        _timeUntilNext = item.time.difference(now);
        return;
      }
    }

    final DateTime tomorrow = now.add(const Duration(days: 1));
    final DateComponents date = DateComponents(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );
    final PrayerTimes tomorrowTimes;
    final PrayerSettings? settings = _settings;

    if (settings != null) {
      tomorrowTimes = PrayerSettingsService.calculatePrayerTimes(
        settings,
        date: tomorrow,
      );
    } else {
      final CalculationParameters params =
          PrayerSettingsService.getCalculationParameters(
              PrayerSettingsService.getDefaultSettings());
      tomorrowTimes = PrayerTimes(
        prayerTimes.coordinates,
        date,
        params,
      );
    }

    _nextPrayer = Prayer.fajr;
    _nextPrayerTime = tomorrowTimes.fajr;
    _timeUntilNext = tomorrowTimes.fajr.difference(now);
  }

  void _updateCountdown() {
    final PrayerTimes? prayerTimes = _prayerTimes;
    if (prayerTimes == null) return;

    final DateTime now = DateTime.now();

    if (prayerTimes.dateComponents.year != now.year ||
        prayerTimes.dateComponents.month != now.month ||
        prayerTimes.dateComponents.day != now.day) {
      _initPrayerTimes();
      return;
    }

    final DateTime? nextTime = _nextPrayerTime;
    if (nextTime == null || !nextTime.isAfter(now)) {
      _calculateNextPrayer();
    }

    if (!mounted) return;

    setState(() {
      _now = now;
      if (_nextPrayerTime != null) {
        _timeUntilNext = _nextPrayerTime!.difference(now);
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_isRefreshingLocation) return;

    setState(() => _isRefreshingLocation = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await PrayerSettingsService.clearPrayerSettings();
      await prefs.setBool(_manualLocationKey, false);
      await prefs.remove(_countryKey);
      await prefs.remove(_cityKey);
      await prefs.remove(_latitudeKey);
      await prefs.remove(_longitudeKey);

      _settings = null;
      _isUsingManualLocation = false;
      _countryName = '';
      _cityName = '';

      await _loadGpsLocation();

      try {
        await PrayerNotificationService.schedulePrayerNotifications();
      } catch (e) {
        debugPrint(
            'Prayer notifications reschedule after GPS change failed: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to use current location: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isRefreshingLocation = false);
      }
    }
  }

  Future<void> _selectManualLocation() async {
    final _PrayerLocation? selected =
        await showModalBottomSheet<_PrayerLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LocationPickerSheet(
        locations: _locations,
      ),
    );

    if (selected == null || !mounted) return;

    final PrayerSettings base =
        _settings ?? PrayerSettingsService.getDefaultSettings();

    ArabCountry selectedCountry = base.selectedCountry;
    for (final ArabCountry country in ArabCountry.values) {
      if (country.label == selected.country) {
        selectedCountry = country;
        break;
      }
    }

    final List<CityInfo> cities =
        arabCitiesByCountry[selectedCountry] ?? const [];
    CityInfo? selectedCity;
    for (final CityInfo city in cities) {
      if (city.name == selected.city) {
        selectedCity = city;
        break;
      }
    }

    if (selectedCity == null) {
      await _calculateForCoordinates(
        selected.latitude,
        selected.longitude,
        locationLabel: '${selected.city} - ${selected.country}',
      );
      return;
    }

    _settings = base.copyWith(
      selectedCountry: selectedCountry,
      selectedCity: selectedCity,
    );

    await PrayerSettingsService.savePrayerSettings(_settings!);

    try {
      await PrayerNotificationService.schedulePrayerNotifications();
    } catch (e) {
      debugPrint(
          'Prayer notifications reschedule after manual location failed: $e');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualLocationKey, true);
    await prefs.setString(_countryKey, selected.country);
    await prefs.setString(_cityKey, selected.city);
    await prefs.setDouble(_latitudeKey, selected.latitude);
    await prefs.setDouble(_longitudeKey, selected.longitude);

    _isUsingManualLocation = true;
    _countryName = selected.country;
    _cityName = selected.city;

    await _calculateForSettings(_settings!);
  }

  Future<void> _openPrayerSettings() async {
    final PrayerSettings settings = _settings ??
        await PrayerSettingsService.loadPrayerSettings() ??
        PrayerSettingsService.getDefaultSettings();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrayerTimesSettingsScreen(
          initialSettings: settings,
          onSettingsSaved: (PrayerSettings saved) {
            _settings = saved;
          },
        ),
      ),
    );

    if (!mounted) return;
    await _initPrayerTimes();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';

    int hour = time.hour;
    final int minute = time.minute;
    final String period = hour >= 12 ? 'م' : 'ص';

    hour %= 12;
    if (hour == 0) hour = 12;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final int total = duration.inSeconds;
    final int hours = total ~/ 3600;
    final int minutes = (total % 3600) ~/ 60;
    final int seconds = total % 60;

    return '${hours.toString().padLeft(2, '0')}: '
        '${minutes.toString().padLeft(2, '0')}: '
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'الصلاة';
    }
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.brightness_5_rounded;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.wb_twilight_rounded;
      case Prayer.isha:
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color gold =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF8F7022);
    final Color text =
        isDark ? const Color(0xFFF0E0B5) : const Color(0xFF1B342B);
    final Color muted =
        isDark ? const Color(0xFF9AB09F) : const Color(0xFF65756D);
    final Color card = isDark ? const Color(0xFF132A22) : Colors.white;
    final Color appBar = isDark ? const Color(0xFF1B342B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBar,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'مواقيت الصلاة',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: gold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'إعدادات مواقيت الصلاة',
            icon: Icon(Icons.tune_rounded, color: gold),
            onPressed: _openPrayerSettings,
          ),
          IconButton(
            tooltip: 'اختيار الموقع',
            icon: Icon(Icons.location_on_rounded, color: gold),
            onPressed: _selectManualLocation,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: gold),
            )
          : RefreshIndicator(
              color: gold,
              onRefresh: _initPrayerTimes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isUsingManualLocation
                                    ? Icons.location_city_rounded
                                    : Icons.gps_fixed_rounded,
                                color: gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isUsingManualLocation
                                        ? 'الموقع المحدد يدويًا'
                                        : 'الموقع الحالي',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _locationName,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, color: gold),
                              onSelected: (value) {
                                if (value == 'manual') {
                                  _selectManualLocation();
                                } else if (value == 'gps') {
                                  _useCurrentLocation();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'manual',
                                  child: Text(
                                    'اختيار البلد والمدينة',
                                    style: TextStyle(fontFamily: 'Amiri'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'gps',
                                  child: Text(
                                    'استخدام موقعي الحالي',
                                    style: TextStyle(fontFamily: 'Amiri'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_isUsingManualLocation) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _isRefreshingLocation
                                ? null
                                : _useCurrentLocation,
                            icon: const Icon(Icons.gps_fixed_rounded),
                            label: const Text(
                              'العودة إلى موقعي الحالي',
                              style: TextStyle(fontFamily: 'Amiri'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الصلاة القادمة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: muted,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          _getPrayerIcon(_nextPrayer),
                          color: gold,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getPrayerName(_nextPrayer),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: gold,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(_nextPrayerTime),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCountdown(_timeUntilNext),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: gold,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'متبقي على الصلاة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildPrayerTile(context, Prayer.fajr, _prayerTimes!.fajr,
                      card, gold, text, muted),
                  _buildPrayerTile(context, Prayer.dhuhr, _prayerTimes!.dhuhr,
                      card, gold, text, muted),
                  _buildPrayerTile(context, Prayer.asr, _prayerTimes!.asr, card,
                      gold, text, muted),
                  _buildPrayerTile(context, Prayer.maghrib,
                      _prayerTimes!.maghrib, card, gold, text, muted),
                  _buildPrayerTile(context, Prayer.isha, _prayerTimes!.isha,
                      card, gold, text, muted),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'يمكنك استخدام الموقع الحالي تلقائيًا أو تحديد البلد والمدينة يدويًا. يتم حفظ اختيارك حتى تغيّره لاحقًا.',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              color: muted,
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${_now.day} ${_getMonthName(_now.month)} ${_now.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerTile(
    BuildContext context,
    Prayer prayer,
    DateTime time,
    Color card,
    Color gold,
    Color text,
    Color muted,
  ) {
    final bool isNext = prayer == _nextPrayer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isNext ? gold.withValues(alpha: 0.12) : card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? gold : gold.withValues(alpha: 0.18),
          width: isNext ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(_getPrayerIcon(prayer), color: gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPrayerName(prayer),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: isNext ? gold : text,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isNext ? 'الصلاة القادمة' : 'وقت الصلاة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontFamily: 'Amiri',
              color: isNext ? gold : text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTime {
  final Prayer prayer;
  final DateTime time;

  const _PrayerTime(this.prayer, this.time);
}

class _PrayerLocation {
  final String country;
  final String city;
  final double latitude;
  final double longitude;

  const _PrayerLocation(
    this.country,
    this.city,
    this.latitude,
    this.longitude,
  );
}

class _LocationPickerSheet extends StatefulWidget {
  final List<_PrayerLocation> locations;

  const _LocationPickerSheet({required this.locations});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color gold =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF8F7022);
    final Color text = theme.colorScheme.onSurface;
    final Color muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    final List<_PrayerLocation> filtered = widget.locations.where((location) {
      if (_query.trim().isEmpty) return true;
      final String q = _query.trim().toLowerCase();
      return location.country.toLowerCase().contains(q) ||
          location.city.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.82,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'اختيار البلد والمدينة',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: text,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن بلد أو مدينة',
                  hintStyle: TextStyle(
                    fontFamily: 'Amiri',
                    color: muted,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: gold),
                  filled: true,
                  fillColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final _PrayerLocation location = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: gold.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.location_city_rounded,
                          color: gold,
                        ),
                      ),
                      title: Text(
                        location.city,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        location.country,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: muted,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, location),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
