import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/adhkar_data.dart';
import 'adhkar_detail_screen.dart'; // تأكد أن هذا الملف موجود باسم adhkar_detail_screen.dart أو dua_detail_screen.dart

class AmaniScreen extends StatefulWidget {
  const AmaniScreen({Key? key}) : super(key: key);

  @override
  State<AmaniScreen> createState() => _AmaniScreenState();
}

class _AmaniScreenState extends State<AmaniScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Color cardColor = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFFD4AF37);

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
          'الأذكار',
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
            // ✅ التصحيح الجذري: استخدام adhkarCategories مباشرة
            itemCount: adhkarCategories.length,
            itemBuilder: (context, index) {
              // ✅ التصحيح الجذري: استخدام المتغير الصحيح
              final category = adhkarCategories[index];
              final duas = category['items'] as List<Map<String, dynamic>>;

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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdhkarDetailScreen(
                              title: category['category']
                                  as String, // ✅ تم التصحيح هنا
                              duas: duas,
                              categoryIndex: index,
                              color: cardColor,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cardColor.withOpacity(0.85),
                              cardColor.withOpacity(0.65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cardColor.withOpacity(0.4),
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
                                gradient: const LinearGradient(
                                  colors: [accentColor, Color(0xFFB8860B)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  category['icon'] as String,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['category']
                                        as String, // ✅ تم التصحيح هنا
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 20,
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${duas.length} ذكر',
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: accentColor.withOpacity(0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
