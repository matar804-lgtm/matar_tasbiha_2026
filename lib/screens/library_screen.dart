import 'package:flutter/material.dart';
import 'quran_page.dart';
import 'duas_screen.dart';
import 'amanie_screen.dart';
import 'ruqyah_screen.dart';
import 'mafateh_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: const Text(
          'المكتبة الإسلامية',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Color(0xFFC9B896),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFC9B896)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildLibraryCard(
              context,
              title: 'القرآن الكريم',
              icon: Icons.menu_book_rounded,
              screen:
                  const QuranPage(), // ✅ سطر نظيف تماماً بدون تعليقات مكسورة
            ),
            _buildLibraryCard(
              context,
              title: 'الأدعية المأثورة',
              icon: Icons.front_hand_rounded,
              screen: const DuasScreen(),
            ),
            _buildLibraryCard(
              context,
              title: 'الأذكار',
              icon: Icons.nights_stay_rounded,
              screen: const AmaniScreen(),
            ),
            _buildLibraryCard(
              context,
              title: 'الرقية الشرعية',
              icon: Icons.auto_awesome_rounded,
              screen: const RuqyahScreen(),
            ),
            _buildLibraryCard(
              context,
              title: 'مفاتيح الفرج',
              icon: Icons.vpn_key_rounded,
              screen: const MafatehScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget screen,
  }) {
    return Card(
      color: const Color(0xFF132A22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFC9B896), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFC9B896).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFC9B896), size: 40),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFFF0E0B5),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
