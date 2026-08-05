import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'amanie_screen.dart';
import 'duas_screen.dart';
import 'mujarrabat_screen.dart'; // ✅ تم إضافة هذا الاستيراد الناقص
import 'qibla_screen.dart';
import 'quran_page.dart'; // ✅ تأكد أن اسم ملفك هو quran_page.dart (أو quran_list_screen.dart)
import 'fadilah_prayer_screen.dart';
import 'prayer_times_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.book,
      'title': 'الأذكار',
      'subtitle': 'أذكار الصباح والمساء والنوم',
      'color': const Color(0xFF1B5E20),
      'gradient': [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      'screen': const AmaniScreen(),
    },
    {
      'icon': Icons.auto_awesome,
      'title': 'الأدعية',
      'subtitle': 'أدعية الأنبياء والمأثورة',
      'color': const Color(0xFF1B5E20),
      'gradient': [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      'screen': const DuasScreen(),
    },
    {
      'icon': Icons.star,
      'title': 'المجربات',
      'subtitle': 'سور قرآنية وأذكار مجربة',
      'color': const Color(0xFFD4AF37),
      'gradient': [const Color(0xFFD4AF37), const Color(0xFFFFD700)],
      'screen': const MujarrabatScreen(), // ✅ الآن سيعمل بشكل صحيح
    },
    {
      'icon': Icons.explore,
      'title': 'اتجاه القبلة',
      'subtitle': 'تحديد دقيق جداً بناءً على موقعك',
      'color': const Color(0xFF00BCD4),
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
      'screen': const QiblaScreen(),
    },
    {
      'icon': Icons.menu_book,
      'title': 'القرآن الكريم',
      'subtitle': 'القرآن الكريم كاملاً مع إشارات مرجعية',
      'color': const Color(0xFF9C27B0),
      'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      'screen':
          const QuranPage(), // ✅ إذا كان اسم الكلاس في ملفك QuranListScreen، غيّر هذا السطر إليها
    },
    {
      'icon': Icons.favorite,
      'title': 'الصلاة الفاضلة',
      'subtitle': 'أفضل الصلوات على النبي ﷺ',
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
      'screen': const FadilahPrayerScreen(),
    },
    {
      'icon': Icons.access_time,
      'title': 'مواقيت الصلاة',
      'subtitle': 'مواقيت الصلاة الدقيقة لمدينتك',
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
      'screen': const PrayerTimesScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'المكتبة',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _controller,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 0.6),
                      ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: Transform.translate(
                  offset: Offset(0, (1 - _controller.value) * 30),
                  child: _buildMenuCard(context, item: item),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required Map<String, dynamic> item}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item['screen'] as Widget),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8)
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (item['color'] as Color).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (item['color'] as Color).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: item['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: (item['color'] as Color).withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
