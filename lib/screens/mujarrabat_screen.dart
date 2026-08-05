import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mujarrabat_duas_data.dart';
import 'surah_detail_screen.dart';
import 'mujarrabat_duas_screen.dart';

class MujarrabatScreen extends StatelessWidget {
  const MujarrabatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'المجربات',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mujarrabatCategories.length,
          itemBuilder: (context, catIndex) {
            final category = mujarrabatCategories[catIndex];
            return _buildCategorySection(context, category, catIndex);
          },
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceFirst('0x', '').replaceFirst('#', '');
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF4CAF50);
    }
  }

  Widget _buildCategorySection(
      BuildContext context, Map<String, dynamic> category, int catIndex) {
    final colorString = category['color'] as String? ?? '0xFF4CAF50';
    final color = _parseColor(colorString);
    final items =
        (category['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category['icon'] as String? ?? '',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category['category'] as String? ?? 'قسم',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map((item) => _buildItemCard(context, item, color)),
        ],
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, Map<String, dynamic> item, Color color) {
    final itemType = item['type'] as String? ?? '';

    if (itemType == 'surah') {
      return _buildSurahCard(context, item, color);
    } else if (itemType == 'dhikr') {
      return _buildDhikrCard(context, item, color);
    } else {
      return _buildDhikrCard(context, item, color);
    }
  }

  Widget _buildSurahCard(
      BuildContext context, Map<String, dynamic> surah, Color color) {
    final surahNumber =
        surah['surahNumber'] as int? ?? (surah['number'] as int? ?? 1);
    final title =
        surah['title'] as String? ?? (surah['name'] as String? ?? 'سورة');
    final content = surah['content'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surahNumber: surahNumber,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (content.isNotEmpty)
                      Text(
                        content,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrCard(
      BuildContext context, Map<String, dynamic> item, Color color) {
    final title =
        item['title'] as String? ?? (item['name'] as String? ?? 'ذكر');
    final content = item['content'] as String? ?? '';
    final count = item['count'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MujarrabatDuasScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (content.isNotEmpty)
                      Text(
                        content.length > 50
                            ? '${content.substring(0, 50)}...'
                            : content,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    else if (count != null)
                      Text(
                        '$count مرة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    else
                      const Text(
                        'اضغط للعرض',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
