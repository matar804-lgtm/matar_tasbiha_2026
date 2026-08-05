import 'package:flutter/material.dart';
import 'dart:math' as math;
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String gregorianDate =
        '${now.day} ${_getMonthName(now.month)} ${now.year}';
    const String hijriDate =
        '16 جمادى الأولى 1446'; // ✅ تم الإصلاح: إضافة const

    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      body: Stack(
        children: [
          // ===== الختم المائي =====
          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: 120,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Text("تسبيحة",
                        style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.03), // ✅ تم الإصلاح
                            fontSize: 70,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: 150,
                  right: 10,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Text("ذكر الله",
                        style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.03), // ✅ تم الإصلاح
                            fontSize: 60,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 300,
                  right: 40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Text("رفيقك الهادئ",
                        style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.04), // ✅ تم الإصلاح
                            fontSize: 40,
                            fontFamily: 'Amiri')),
                  ),
                ),
                Positioned(
                  bottom: 300,
                  left: 30,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Text("للعبادة اليومية",
                        style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.04), // ✅ تم الإصلاح
                            fontSize: 40,
                            fontFamily: 'Amiri')),
                  ),
                ),
              ],
            ),
          ),

          // ===== المحتوى الرئيسي =====
          SafeArea(
            child: Column(
              children: [
                // ===== الهيدر العلوي =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B342B),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A4A3D), width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ زر HOME + زر الإعدادات (الترس)
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _goToHome(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9B896)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.home_rounded,
                                      color: Color(0xFFC9B896), size: 18),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SettingsScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9B896)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.settings_rounded,
                                      color: Color(0xFFC9B896), size: 18),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 25,
                                  height: 1,
                                  color: const Color(0xFFC9B896)),
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFC9B896), size: 12),
                              const SizedBox(width: 6),
                              Container(
                                  width: 25,
                                  height: 1,
                                  color: const Color(0xFFC9B896)),
                            ],
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "السلام عليكم",
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFF0E0B5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "تطبيق التسبيح",
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFFC9B896),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "إعداد: محمد مطر",
                        style: TextStyle(
                            color: Color(0xFF9AB09F),
                            fontSize: 10,
                            letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ===== منطقة الأيقونات الدائرية =====
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(420, 420),
                        painter: IslamicPatternPainter(),
                      ),
                      CustomPaint(
                        size: const Size(340, 340),
                        painter: DottedCircleOriginalPainter(),
                      ),
                      const OriginalCircularMenu(),
                      const OriginalCenterButton(),

                      // ===== المستطيل الأيمن: الصلاة القادمة =====
                      Positioned(
                        right: 12,
                        bottom: 20,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A22)
                                .withValues(alpha: 0.9), // ✅ تم الإصلاح
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFC9B896)
                                  .withValues(alpha: 0.5), // ✅ تم الإصلاح
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.3), // ✅ تم الإصلاح
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
                                  color: const Color(0xFFC9B896)
                                      .withValues(alpha: 0.15), // ✅ تم الإصلاح
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
                                      "الصلاة القادمة",
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(0xFF8AB09A),
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      "العصر • 15:23",
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(0xFFF0E0B5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      "متبقي 42 د",
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: const Color(0xFFC9B896).withValues(
                                            alpha:
                                                0.8), // ✅ تم الإصلاح + إضافة const
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9B896)
                                      .withValues(alpha: 0.15), // ✅ تم الإصلاح
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

                      // ===== المستطيل الأيسر: التاريخ =====
                      Positioned(
                        left: 12,
                        bottom: 20,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A22)
                                .withValues(alpha: 0.9), // ✅ تم الإصلاح
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFC9B896)
                                  .withValues(alpha: 0.5), // ✅ تم الإصلاح
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.3), // ✅ تم الإصلاح
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
                                  color: const Color(0xFFC9B896)
                                      .withValues(alpha: 0.15), // ✅ تم الإصلاح
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
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
                                      "التاريخ",
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(0xFF8AB09A),
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      gregorianDate,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(0xFFF0E0B5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      hijriDate,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: const Color(0xFFC9B896).withValues(
                                            alpha:
                                                0.8), // ✅ تم الإصلاح + إضافة const
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9B896)
                                      .withValues(alpha: 0.15), // ✅ تم الإصلاح
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.event_rounded,
                                  color: Color(0xFFC9B896),
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

// ===== الـ 8 أيقونات الموزعة دائرياً =====
class OriginalCircularMenu extends StatelessWidget {
  const OriginalCircularMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ تم الإصلاح: إضافة const للقائمة لحل prefer_const_literals_to_create_immutables
    const List<Map<String, dynamic>> items = [
      {
        'icon': Icons.menu_book_rounded,
        'label': 'القرآن',
        'screen': QuranPage()
      },
      {
        'icon': Icons.access_time_filled_rounded,
        'label': 'المواقيت',
        'screen': PrayerTimesScreen()
      },
      {
        'icon': Icons.explore_rounded,
        'label': 'القبلة',
        'screen': QiblaScreen()
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'الرقية',
        'screen': RuqyahScreen()
      },
      {
        'icon': Icons.vpn_key_rounded,
        'label': 'مفاتيح الفرج',
        'screen': MafatehScreen()
      },
      {
        'icon': Icons.front_hand_rounded,
        'label': 'الأدعية',
        'screen': DuasScreen()
      },
      {
        'icon': Icons.nights_stay_rounded,
        'label': 'الأذكار',
        'screen': AmaniScreen()
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'الفاضلة',
        'screen': FadilahPrayerScreen()
      },
    ];

    return SizedBox(
      width: 380,
      height: 420,
      child: Stack(
        children: List.generate(8, (index) {
          double angle = (2 * math.pi / 8) * index - (math.pi / 2);
          double radius = 155;
          double x = radius * math.cos(angle);
          double y = radius * math.sin(angle);

          return Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(x, y),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => items[index]['screen'] as Widget),
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
                        color: const Color(0xFF132A22)
                            .withValues(alpha: 0.85), // ✅ تم الإصلاح
                        border: Border.all(
                            color: const Color(0xFFE8D5A3), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.3), // ✅ تم الإصلاح
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Icon(items[index]['icon'] as IconData,
                          color: const Color(0xFFE8D5A3), size: 24),
                    ),
                    const SizedBox(height: 5),
                    Text(items[index]['label'] as String,
                        style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFD8C9A0),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ===== الزر الرئيسي الكبير في الوسط =====
class OriginalCenterButton extends StatelessWidget {
  const OriginalCenterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment.topCenter,
            colors: [Color(0xFFEAD79F), Color(0xFFC9A86A), Color(0xFF8C6A2F)],
          ),
          border: Border.all(color: const Color(0xFFF0E0B5), width: 3.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5), // ✅ تم الإصلاح
                blurRadius: 20,
                spreadRadius: 1),
            BoxShadow(
                color: const Color(0xFFC9A86A)
                    .withValues(alpha: 0.4), // ✅ تم الإصلاح
                blurRadius: 30,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 38, color: Color(0xFFFFF8E1)),
            const SizedBox(height: 2),
            const Text(
              "تسبيح",
              style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Color(0xFF2C1E08),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1E08)
                    .withValues(alpha: 0.15), // ✅ تم الإصلاح
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "ابدأ الآن",
                style: TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFF2C1E08),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== رسام الزخرفة =====
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9B896).withValues(alpha: 0.06) // ✅ تم الإصلاح
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(center, 70 + i * 38, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class DottedCircleOriginalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9B896).withValues(alpha: 0.25) // ✅ تم الإصلاح
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final center = Offset(size.width / 2, size.height / 2);
    for (double a = 0; a < 2 * math.pi; a += 0.08) {
      double x = center.dx + 148 * math.cos(a);
      double y = center.dy + 148 * math.sin(a);
      canvas.drawCircle(Offset(x, y), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
