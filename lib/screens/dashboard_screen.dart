import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/prayer_settings_model.dart';
import '../services/prayer_settings_service.dart';

import 'home_screen.dart';
import 'quran_page.dart';
import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'duas_screen.dart';
import 'amanie_screen.dart';
import 'fadilah_prayer_screen.dart';
import 'ruqyah_screen.dart';
import 'mafateh_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ============================================================
  // مواقيت الصلاة
  // ============================================================

  PrayerTimes? _prayerTimes;

  String _prayerLocation = 'الموقع غير متاح';

  Prayer _nextPrayer = Prayer.none;

  DateTime? _nextPrayerTime;

  Duration _timeUntilNext = Duration.zero;

  bool _isPrayerLoading = true;

  Timer? _countdownTimer;

  // ============================================================
  // دورة حياة الصفحة
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadPrayerTimes();

    // تحديث العداد كل ثانية
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updatePrayerCountdown();
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();

    super.dispose();
  }

  // ============================================================
  // الانتقال إلى الصفحة الرئيسية
  // ============================================================

  void _goToHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ============================================================
  // تحميل مواقيت الصلاة
  // ============================================================

  Future<void> _loadPrayerTimes() async {
    try {
      // استخدم إعدادات الصلاة الموحدة إن وُجدت، حتى يطابق
      // المستطيل الصغير والشاشة الرئيسية شاشة مواقيت الصلاة والإشعارات.
      final PrayerSettings? savedSettings =
          await PrayerSettingsService.loadPrayerSettings();

      if (savedSettings != null) {
        final PrayerTimes prayerTimes =
            PrayerSettingsService.calculatePrayerTimes(savedSettings);

        final Prayer nextPrayer = prayerTimes.nextPrayer();
        DateTime? nextPrayerTime;
        if (nextPrayer != Prayer.none) {
          nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
        }

        if (!mounted) return;

        setState(() {
          _prayerTimes = prayerTimes;
          _nextPrayer = nextPrayer == Prayer.none ? Prayer.fajr : nextPrayer;
          _nextPrayerTime = nextPrayerTime;
          _timeUntilNext = nextPrayerTime == null
              ? Duration.zero
              : nextPrayerTime.difference(DateTime.now());
          _prayerLocation =
              '${savedSettings.selectedCity.name} - ${savedSettings.selectedCountry.label}';
          _isPrayerLoading = false;
        });
        return;
      }

      // توافق مع النسخ التي لم تحفظ إعدادات موحدة بعد.
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _isPrayerLoading = false;
          _prayerLocation = 'الموقع غير متاح';
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final Coordinates coordinates = Coordinates(
        position.latitude,
        position.longitude,
      );

      final CalculationParameters params =
          PrayerSettingsService.getCalculationParameters(
              PrayerSettingsService.getDefaultSettings());

      final PrayerTimes prayerTimes = PrayerTimes.today(
        coordinates,
        params,
      );

      final Prayer nextPrayer = prayerTimes.nextPrayer();
      DateTime? nextPrayerTime;

      if (nextPrayer != Prayer.none) {
        nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
      }

      if (!mounted) return;

      setState(() {
        _prayerTimes = prayerTimes;
        _nextPrayer = nextPrayer == Prayer.none ? Prayer.fajr : nextPrayer;
        _nextPrayerTime = nextPrayerTime;

        if (nextPrayerTime != null) {
          _timeUntilNext = nextPrayerTime.difference(DateTime.now());
        } else {
          _timeUntilNext = Duration.zero;
        }

        _prayerLocation = '${position.latitude.toStringAsFixed(2)}, '
            '${position.longitude.toStringAsFixed(2)}';
        _isPrayerLoading = false;
      });
    } catch (e) {
      debugPrint(
        'خطأ في تحميل مواقيت الصلاة من Dashboard: $e',
      );

      if (!mounted) return;

      setState(() {
        _isPrayerLoading = false;
        _prayerLocation = 'تعذر تحديد الموقع';
      });
    }
  }

  // ============================================================
  // تحديث العداد كل ثانية
  // ============================================================

  void _updatePrayerCountdown() {
    final PrayerTimes? prayerTimes = _prayerTimes;
    if (prayerTimes == null) {
      return;
    }

    final DateTime now = DateTime.now();

    // إذا أصبحنا في يوم جديد، أعد تحميل مواقيت اليوم.
    final DateTime prayerDate = DateTime(
      prayerTimes.dateComponents.year,
      prayerTimes.dateComponents.month,
      prayerTimes.dateComponents.day,
    );

    final bool dayChanged = prayerDate.year != now.year ||
        prayerDate.month != now.month ||
        prayerDate.day != now.day;

    if (dayChanged) {
      _loadPrayerTimes();
      return;
    }

    final Prayer nextPrayer = prayerTimes.nextPrayer();

    // توجد صلاة قادمة اليوم.
    if (nextPrayer != Prayer.none) {
      final DateTime? nextTime = prayerTimes.timeForPrayer(nextPrayer);

      if (nextTime == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _nextPrayer = nextPrayer;
        _nextPrayerTime = nextTime;
        _timeUntilNext = nextTime.difference(now);
      });

      return;
    }

    // انتهت صلاة العشاء:
    // الصلاة القادمة هي فجر اليوم التالي.
    try {
      final DateTime tomorrow = now.add(const Duration(days: 1));

      final DateComponents tomorrowDate = DateComponents(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
      );

      final CalculationParameters params =
          PrayerSettingsService.getCalculationParameters(
              PrayerSettingsService.getDefaultSettings());

      final PrayerTimes tomorrowPrayerTimes = PrayerTimes(
        prayerTimes.coordinates,
        tomorrowDate,
        params,
      );

      final DateTime tomorrowFajr = tomorrowPrayerTimes.fajr;

      if (!mounted) {
        return;
      }

      setState(() {
        _nextPrayer = Prayer.fajr;
        _nextPrayerTime = tomorrowFajr;
        _timeUntilNext = tomorrowFajr.difference(now);
      });
    } catch (e) {
      debugPrint(
        'خطأ في حساب فجر اليوم التالي في Dashboard: $e',
      );
    }
  }
  // ============================================================
  // اسم الصلاة
  // ============================================================

  String _getPrayerName(
    Prayer prayer,
  ) {
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

  // ============================================================
  // تنسيق وقت الصلاة
  // ============================================================

  String _formatPrayerTime(
    DateTime? time,
  ) {
    if (time == null) {
      return '--:--';
    }

    int hour = time.hour;

    final int minute = time.minute;

    final String period = hour >= 12 ? 'م' : 'ص';

    hour %= 12;

    if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  // ============================================================
  // تنسيق العداد
  // ============================================================

  String _formatCountdown(
    Duration duration,
  ) {
    if (duration.isNegative) {
      return '00:00:00';
    }

    final int totalSeconds = duration.inSeconds;

    final int hours = totalSeconds ~/ 3600;

    final int minutes = (totalSeconds % 3600) ~/ 60;

    final int seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // التاريخ
  // ============================================================

  String _getMonthName(
    int month,
  ) {
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
      'ديسمبر',
    ];

    return months[month - 1];
  }

  // ============================================================
  // مستطيل الصلاة القادم
  // ============================================================

  Widget _buildNextPrayerCard() {
    final String prayerName = _getPrayerName(_nextPrayer);

    final String prayerTime = _formatPrayerTime(_nextPrayerTime);

    final String countdown = _formatCountdown(_timeUntilNext);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Positioned(
      right: 12,
      bottom: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrayerTimesScreen(),
              ),
            );

            if (!mounted) return;
            await _loadPrayerTimes();
          },
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.secondary.withValues(alpha: 0.55),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Color(0xFFC9B896),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'الصلاة القادمة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFF8AB09A),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _isPrayerLoading
                            ? 'جاري الحساب...'
                            : '$prayerName • $prayerTime',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFFF0E0B5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _isPrayerLoading ? '...' : 'متبقي $countdown',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: scheme.secondary.withValues(alpha: 0.85),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFFC9B896),
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // واجهة Dashboard
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final DateTime now = DateTime.now();

    final String gregorianDate = '${now.day} '
        '${_getMonthName(now.month)} '
        '${now.year}';

    const String hijriDate = '16 جمادى الأولى 1446';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ======================================================
          // الختم المائي
          // ======================================================

          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: 120,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Text(
                      'تسبيحة',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.03,
                        ),
                        fontSize: 70,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 150,
                  right: 10,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Text(
                      'ذكر الله',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.03,
                        ),
                        fontSize: 60,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 300,
                  right: 40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Text(
                      'رفيقك الهادئ',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.04,
                        ),
                        fontSize: 40,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 300,
                  left: 30,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Text(
                      'للعبادة اليومية',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.04,
                        ),
                        fontSize: 40,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // المحتوى الرئيسي
          // ======================================================

          SafeArea(
            child: Column(
              children: [
                // ==================================================
                // الهيدر العلوي
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _goToHome(
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC9B896,
                                    ).withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: Color(
                                      0xFFC9B896,
                                    ),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC9B896,
                                    ).withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings_rounded,
                                    color: Color(
                                      0xFFC9B896,
                                    ),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 25,
                                height: 1,
                                color: const Color(
                                  0xFFC9B896,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFC9B896),
                                size: 12,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Container(
                                width: 25,
                                height: 1,
                                color: const Color(
                                  0xFFC9B896,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'السلام عليكم',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFF0E0B5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      const Text(
                        'تطبيق التسبيح',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFFC9B896),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      const Text(
                        'إعداد: محمد مطر',
                        style: TextStyle(
                          color: Color(0xFF9AB09F),
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==================================================
                // منطقة الأيقونات الدائرية
                // ==================================================

                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: 420,
                          height: 420,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(
                                  420,
                                  420,
                                ),
                                painter: IslamicPatternPainter(),
                              ),
                              CustomPaint(
                                size: const Size(
                                  340,
                                  340,
                                ),
                                painter: DottedCircleOriginalPainter(),
                              ),
                              const OriginalCircularMenu(),
                              const OriginalCenterButton(),
                            ],
                          ),
                        ),
                      ),

                      // =================================================

                      _buildNextPrayerCard(),

                      // =================================================
                      // مستطيل التاريخ
                      // =================================================

                      Positioned(
                        left: 12,
                        bottom: 20,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF132A22,
                            ).withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            border: Border.all(
                              color: const Color(
                                0xFFC9B896,
                              ).withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFC9B896,
                                  ).withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(
                                    0xFFC9B896,
                                  ),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'التاريخ',
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(
                                          0xFF8AB09A,
                                        ),
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      gregorianDate,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(
                                          0xFFF0E0B5,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      hijriDate,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: const Color(
                                          0xFFC9B896,
                                        ).withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFC9B896,
                                  ).withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.event_rounded,
                                  color: Color(
                                    0xFFC9B896,
                                  ),
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// الـ 8 أيقونات الموزعة دائرياً
// ================================================================

class OriginalCircularMenu extends StatelessWidget {
  const OriginalCircularMenu({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const List<Map<String, dynamic>> items = [
      {
        'icon': Icons.menu_book_rounded,
        'label': 'القرآن',
        'screen': QuranPage(),
      },
      {
        'icon': Icons.access_time_filled_rounded,
        'label': 'المواقيت',
        'screen': PrayerTimesScreen(),
      },
      {
        'icon': Icons.explore_rounded,
        'label': 'القبلة',
        'screen': QiblaScreen(),
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'الرقية',
        'screen': RuqyahScreen(),
      },
      {
        'icon': Icons.vpn_key_rounded,
        'label': 'مفاتيح الفرج',
        'screen': MafatehScreen(),
      },
      {
        'icon': Icons.front_hand_rounded,
        'label': 'الأدعية',
        'screen': DuasScreen(),
      },
      {
        'icon': Icons.nights_stay_rounded,
        'label': 'الأذكار',
        'screen': AmaniScreen(),
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'الفاضلة',
        'screen': FadilahPrayerScreen(),
      },
    ];

    return SizedBox(
      width: 380,
      height: 420,
      child: Stack(
        children: List.generate(
          8,
          (index) {
            final double angle = (2 * math.pi / 8) * index - (math.pi / 2);

            const double radius = 155;

            final double x = radius * math.cos(angle);

            final double y = radius * math.sin(angle);

            return Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(x, y),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => items[index]['screen'] as Widget,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF132A22,
                          ).withValues(
                            alpha: 0.85,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE8D5A3,
                            ),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),
                        child: Icon(
                          items[index]['icon'] as IconData,
                          color: const Color(
                            0xFFE8D5A3,
                          ),
                          size: 24,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        items[index]['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(
                            0xFFD8C9A0,
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// الزر الرئيسي الكبير في الوسط
// ================================================================

class OriginalCenterButton extends StatelessWidget {
  const OriginalCenterButton({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment.topCenter,
            colors: [
              Color(0xFFEAD79F),
              Color(0xFFC9A86A),
              Color(0xFF8C6A2F),
            ],
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.5,
              ),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFFC9A86A).withValues(
                alpha: 0.4,
              ),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 38,
              color: Color(0xFFFFF8E1),
            ),
            const SizedBox(
              height: 2,
            ),
            const Text(
              'تسبيح',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFF2C1E08),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF2C1E08,
                ).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: const Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Color(0xFF2C1E08),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// رسام الزخرفة
// ================================================================

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = const Color(
        0xFFC9B896,
      ).withValues(
        alpha: 0.06,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        center,
        70 + i * 38,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ================================================================
// الدائرة المنقطة
// ================================================================

class DottedCircleOriginalPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = const Color(
        0xFFC9B896,
      ).withValues(
        alpha: 0.25,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    for (double a = 0; a < 2 * math.pi; a += 0.08) {
      final double x = center.dx + 148 * math.cos(a);

      final double y = center.dy + 148 * math.sin(a);

      canvas.drawCircle(
        Offset(x, y),
        0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
