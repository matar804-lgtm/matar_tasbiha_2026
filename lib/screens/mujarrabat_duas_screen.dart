import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mujarrabat_duas_data.dart';
import 'surah_detail_screen.dart';

class MujarrabatDuasScreen extends StatefulWidget {
  const MujarrabatDuasScreen({Key? key}) : super(key: key);

  @override
  State<MujarrabatDuasScreen> createState() => _MujarrabatDuasScreenState();
}

class _MujarrabatDuasScreenState extends State<MujarrabatDuasScreen> {
  int _currentCategoryIndex = 0;
  Map<String, int> _counters = {};

  @override
  Widget build(BuildContext context) {
    final category = mujarrabatCategories[_currentCategoryIndex];
    final items = category['items'] as List<Map<String, dynamic>>;
    final colorHex = int.parse(
        (category['color'] as String).replaceFirst('0x', ''),
        radix: 16);
    final categoryColor = Color(colorHex);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_mujarrabat.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          '${category['icon']} ${category['category']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: mujarrabatCategories.length,
                    itemBuilder: (context, index) {
                      final cat = mujarrabatCategories[index];
                      final isSelected = index == _currentCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentCategoryIndex = index;
                            _counters = {};
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD4AF37).withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat['icon'] as String,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                cat['category'] as String,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 13,
                                  color: isSelected
                                      ? const Color(0xFFD4AF37)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemType = item['type'] as String;
                      final itemKey = '${_currentCategoryIndex}_$index';
                      final currentCount = _counters[itemKey] ?? 0;
                      final targetCount = item['count'] as int? ?? 1;
                      final isCompleted = currentCount >= targetCount;

                      if (itemType == 'surah') {
                        return _buildSurahCard(item);
                      }
                      if (itemType == 'salah') {
                        return _buildSalahCard(item, categoryColor, isCompleted,
                            currentCount, targetCount, itemKey);
                      }
                      return _buildDhikrCard(item, categoryColor, isCompleted,
                          currentCount, targetCount, itemKey);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> item) {
    final surahNumber = item['surahNumber'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SurahDetailScreen(
                      surahNumber: surahNumber, startAyah: 1)));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.35),
                  const Color(0xFF4CAF50).withOpacity(0.15)
                ]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.menu_book,
                          color: Color(0xFF4CAF50), size: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String,
                            style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item['content'] as String,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFF4CAF50), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF4CAF50), thickness: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFD4AF37), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(item['reference'] as String,
                          style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.6))),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)]),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.read_more, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('افتح السورة',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalahCard(Map<String, dynamic> item, Color categoryColor,
      bool isCompleted, int currentCount, int targetCount, String itemKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.2),
              const Color(0xFF4CAF50).withOpacity(0.05)
            ]),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isCompleted
                ? const Color(0xFFD4AF37)
                : const Color(0xFF4CAF50).withOpacity(0.5),
            width: isCompleted ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('ﷺ',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(item['title'] as String,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF4CAF50).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                    isCompleted ? '✓ تم' : '$currentCount / $targetCount',
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF4CAF50), thickness: 1),
          const SizedBox(height: 12),
          Text(item['content'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 17,
                  color: Colors.white,
                  height: 2)),
          const SizedBox(height: 12),
          if (item['reference'] != null)
            Text(' ${item['reference']}',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          if (!isCompleted)
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _counters[itemKey] = currentCount + 1;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)]),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ]),
                  child: const Text('اضغط للعد',
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDhikrCard(Map<String, dynamic> item, Color categoryColor,
      bool isCompleted, int currentCount, int targetCount, String itemKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFD4AF37).withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isCompleted
                ? const Color(0xFFD4AF37)
                : Colors.white.withOpacity(0.2),
            width: isCompleted ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(item['title'] as String,
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: isCompleted
                              ? const Color(0xFFD4AF37)
                              : Colors.white,
                          fontWeight: FontWeight.bold))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : categoryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                    isCompleted ? '✓ تم' : '$currentCount / $targetCount',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFD4AF37), thickness: 1),
          const SizedBox(height: 12),
          Text(item['content'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.8)),
          const SizedBox(height: 10),
          if (item['reference'] != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(item['reference'] as String,
                          style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 12,
                              color: Color(0xFFD4AF37),
                              fontStyle: FontStyle.italic))),
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (!isCompleted)
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _counters[itemKey] = currentCount + 1;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        categoryColor,
                        categoryColor.withOpacity(0.7)
                      ]),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: categoryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ]),
                  child: const Text('اضغط للعد',
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
