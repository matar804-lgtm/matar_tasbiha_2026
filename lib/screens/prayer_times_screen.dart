import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  String _locationName = 'جاري تحديد الموقع...';
  DateTime _now = DateTime.now();
  Prayer _nextPrayer = Prayer.fajr;
  Duration _timeUntilNext = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPrayerTimes();
  }

  Future<void> _initPrayerTimes() async {
    try {
      // 1. التحقق من صلاحيات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationName = 'تم رفض إذن الموقع';
          _isLoading = false;
        });
        return;
      }

      // 2. جلب الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 3. حساب مواقيت الصلاة
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;
      _prayerTimes = PrayerTimes.today(coordinates, params);

      // 4. تحديد الصلاة القادمة
      _nextPrayer = _prayerTimes!.nextPrayer();
      if (_nextPrayer == Prayer.none) {
        _nextPrayer = Prayer.fajr; // fallback
      }
      _timeUntilNext =
          _prayerTimes!.timeForPrayer(_nextPrayer)!.difference(_now);

      setState(() {
        _locationName =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'خطأ في تحديد الموقع';
        _isLoading = false;
      });
    }
  }

  // دالة تنسيق الوقت (آمنة ولا تعتمد على locale)
  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
        return '';
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
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: const Text('مواقيت الصلاة',
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : RefreshIndicator(
              onRefresh: _initPrayerTimes,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // بطاقة التاريخ والموقع
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1B342B), Color(0xFF2A4A3D)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_now.day} ${_getMonthName(_now.month)} ${_now.year}',
                          style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Color(0xFF9AB09F), size: 18),
                            const SizedBox(width: 5),
                            Text(_locationName,
                                style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14,
                                    color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // بطاقة الصلاة القادمة
                  if (_prayerTimes != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('الصلاة القادمة',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  color: Color(0xFF9AB09F))),
                          const SizedBox(height: 10),
                          Text(_getPrayerName(_nextPrayer),
                              style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 32,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            'متبقي ${_timeUntilNext.inHours} ساعة و ${_timeUntilNext.inMinutes % 60} دقيقة',
                            style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // قائمة الصلوات الخمس
                  if (_prayerTimes != null) ...[
                    _buildPrayerTile(Prayer.fajr, _prayerTimes!.fajr),
                    _buildPrayerTile(Prayer.dhuhr, _prayerTimes!.dhuhr),
                    _buildPrayerTile(Prayer.asr, _prayerTimes!.asr),
                    _buildPrayerTile(Prayer.maghrib, _prayerTimes!.maghrib),
                    _buildPrayerTile(Prayer.isha, _prayerTimes!.isha),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerTile(Prayer prayer, DateTime? time) {
    final isNext = prayer == _nextPrayer;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
            : const Color(0xFF132A22).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isNext
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withValues(alpha: 0.3),
            width: isNext ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(_getPrayerIcon(prayer),
                color: const Color(0xFFD4AF37), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getPrayerName(prayer),
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: isNext ? const Color(0xFFD4AF37) : Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isNext ? 'الصلاة القادمة' : 'وقت الصلاة',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        color:
                            isNext ? const Color(0xFFD4AF37) : Colors.white70)),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: isNext ? const Color(0xFFD4AF37) : Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
      'ديسمبر'
    ];
    return months[month - 1];
  }
}
