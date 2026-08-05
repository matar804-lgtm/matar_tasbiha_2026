import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ═══════════════ التصميم الأول: الكلاسيكي الأنيق ══════════════
class ClassicHomeDesign extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final VoidCallback onTasbih;
  final VoidCallback onQuran;
  final VoidCallback onAdhkar;
  final VoidCallback onQibla;

  static const Color goldColor = Color(0xFFD4AF37);

  const ClassicHomeDesign(
      {Key? key,
      required this.hijriDate,
      required this.gregorianDate,
      required this.onTasbih,
      required this.onQuran,
      required this.onAdhkar,
      required this.onQibla})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1A1F3A),
            Color(0xFF0A0E27)
          ])),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(children: [
              Text(gregorianDate,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: Colors.white70)),
              const SizedBox(height: 5),
              Text(hijriDate,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: goldColor,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 30),
            const Text('أهلاً بك',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: goldColor)),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(Icons.menu_book, 'القرآن', onQuran),
                _buildCircleButton(Icons.touch_app, 'التسبيح', onTasbih),
                _buildCircleButton(Icons.nights_stay, 'الأذكار', onAdhkar),
                _buildCircleButton(Icons.explore, 'القبلة', onQibla),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                  boxShadow: [
                    BoxShadow(
                        color: goldColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3)
                  ]),
              child: Icon(icon, size: 35, color: const Color(0xFF0A0E27))),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Amiri', fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}

// ═══════════════ التصميم الثاني: العمودي المزخرف ══════════════
class VerticalHomeDesign extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final VoidCallback onTasbih;
  final VoidCallback onQuran;
  final VoidCallback onAdhkar;
  final VoidCallback onQibla;
  final VoidCallback onSettings;

  static const Color goldColor = Color(0xFFD4AF37);

  const VerticalHomeDesign(
      {Key? key,
      required this.hijriDate,
      required this.gregorianDate,
      required this.onTasbih,
      required this.onQuran,
      required this.onAdhkar,
      required this.onQibla,
      required this.onSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1A1F3A),
            Color(0xFF0A0E27)
          ])),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(children: [
              Text(gregorianDate,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: Colors.white70)),
              const SizedBox(height: 5),
              Text(hijriDate,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: goldColor,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            Icon(Icons.mosque, size: 80, color: goldColor.withOpacity(0.6)),
            const SizedBox(height: 15),
            const Text('تسبيحة',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: goldColor)),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildOrnateButton(Icons.touch_app, 'التسبيح', onTasbih),
                _buildOrnateButton(Icons.menu_book, 'القرآن', onQuran),
                _buildOrnateButton(Icons.nights_stay, 'الأذكار', onAdhkar),
                _buildOrnateButton(Icons.explore, 'القبلة', onQibla),
                _buildOrnateButton(Icons.settings, 'الإعدادات', onSettings),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnateButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
            border: Border.all(color: const Color(0xFF0A0E27), width: 3),
            boxShadow: [
              BoxShadow(
                  color: goldColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF0A0E27)),
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11,
                    color: Color(0xFF0A0E27),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════ التصميم الثالث: الدائرة المركزية ══════════════
class CentralCircleHomeDesign extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final VoidCallback onTasbih;
  final VoidCallback onQuran;
  final VoidCallback onAdhkar;
  final VoidCallback onQibla;
  final VoidCallback onSettings;

  static const Color goldColor = Color(0xFFD4AF37);

  const CentralCircleHomeDesign(
      {Key? key,
      required this.hijriDate,
      required this.gregorianDate,
      required this.onTasbih,
      required this.onQuran,
      required this.onAdhkar,
      required this.onQibla,
      required this.onSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1A1F3A),
            Color(0xFF0A0E27)
          ])),
      child: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: 0.08,
                  child: CustomPaint(painter: _IslamicPatternPainter()))),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Column(children: [
                  Text(gregorianDate,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text(hijriDate,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: goldColor,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onTasbih();
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [
                        Color(0xFFFFE066),
                        Color(0xFFD4AF37),
                        Color(0xFFB8860B)
                      ]),
                      boxShadow: [
                        BoxShadow(
                            color: goldColor.withOpacity(0.6),
                            blurRadius: 50,
                            spreadRadius: 15),
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            size: 60, color: Color(0xFF0A0E27)),
                        const SizedBox(height: 15),
                        const Text('ابدأ التسبيح',
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A0E27))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildFeatureButton(
                          Icons.menu_book_rounded, 'القرآن', onQuran),
                      _buildFeatureButton(
                          Icons.nights_stay_rounded, 'الأذكار', onAdhkar),
                      _buildFeatureButton(
                          Icons.explore_rounded, 'القبلة', onQibla),
                      _buildFeatureButton(
                          Icons.settings_rounded, 'الإعدادات', onSettings),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
            color: const Color(0xFF162447).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                  color: goldColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: goldColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 35, color: goldColor)),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// رسام الزخارف الإسلامية
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = center.dx + 250 * math.cos(angle);
      final y = center.dy + 250 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 50, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
