import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1628),
                Color(0xFF1A2F4A),
                Color(0xFF0D1B2A)
              ]),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // === أيقونة المسجد ===
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A2332).withOpacity(0.9),
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              blurRadius: 25,
                              spreadRadius: 5)
                        ],
                      ),
                      child: const Icon(Icons.mosque,
                          size: 65, color: Color(0xFFD4AF37)),
                    ),
                    const SizedBox(height: 15),

                    // === اسم التطبيق ===
                    const Text('تسبيحه',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 44,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(0, 3))
                            ])),
                    const SizedBox(height: 5),
                    const Text('رفيقك في ذكر الله',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: Colors.white)),
                    const SizedBox(height: 25),

                    // === بطاقة الآية ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0A0F1A).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 2)),
                      child: const Column(
                        children: [
                          Text('أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 24,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5)),
                          SizedBox(height: 10),
                          Text('سورة الرعد - آية 28',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 14,
                                  color: Colors.white70)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ === بطاقة الإهداء والصدقة الجارية (تمت إضافتها) ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF3D2817), Color(0xFF5D3A1F)]),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.favorite,
                              color: Color(0xFFE8837C), size: 28),
                          SizedBox(height: 8),
                          Text(
                            'صدقة جارية',
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 22,
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'عني وعن روح والدي ووالدتي رحمهما الله',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // === زر ابدأ التسبيح ===
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const LoginScreen()));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFFFFD700).withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 3)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ابدأ التسبيح',
                                style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 26,
                                    color: Color(0xFF0A0F1A),
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Container(
                                width: 35,
                                height: 35,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF0A0F1A),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.play_arrow,
                                    color: Color(0xFFFFD700), size: 24)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // === معلومات المطور ===
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              width: 1)),
                      child: const Column(
                        children: [
                          Text('إعداد وتطوير',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 13,
                                  color: Colors.white70)),
                          SizedBox(height: 5),
                          Text('محمد مطر',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 20,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text('AppNest Studio',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 13,
                                  color: Colors.white60)),
                          SizedBox(height: 10),
                          Text('الإصدار 1.1.0',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 13,
                                  color: Color(0xFF0A0F1A),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
