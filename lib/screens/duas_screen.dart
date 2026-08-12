import 'package:flutter/material.dart';
import '../data/duas_data.dart';
import 'dua_detail_screen.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B342B),
        elevation: 0,
        title: const Text(
          'الأدعية المأثورة',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'موسوعة شاملة للأدعية من القرآن والسنة',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allDuasCategories.length,
        itemBuilder: (context, index) {
          final category = allDuasCategories[index];
          return Card(
            color: const Color(0xFF132A22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFC9B896), width: 1),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== عنوان الفئة =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B342B),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFC9B896).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFF0E0B5),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFC9B896).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${category.duas.length}',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFC9B896),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ===== قائمة الأدعية =====
                ...category.duas.map((dua) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DuaDetailScreen(
                            title: dua.title,
                            content: dua.arabic,
                            virtue: dua.virtue,
                            repeatCount: dua.repeatCount,
                            source: dua.source,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                const Color(0xFFC9B896).withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9B896)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFC9B896),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dua.title,
                                  style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    color: Color(0xFFF0E0B5),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      color: const Color(0xFFD4AF37),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'التكرار: ${dua.repeatCount}',
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Color(0xFFD4AF37),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: const Color(0xFF9AB09F),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        dua.source,
                                        style: const TextStyle(
                                          fontFamily: 'Amiri',
                                          color: Color(0xFF9AB09F),
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFC9B896),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
