import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/special_adhkar_data.dart';

class SpecialAdhkarScreen extends StatefulWidget {
  const SpecialAdhkarScreen({Key? key}) : super(key: key);

  @override
  State<SpecialAdhkarScreen> createState() => _SpecialAdhkarScreenState();
}

class _SpecialAdhkarScreenState extends State<SpecialAdhkarScreen> {
  final List<int> _counters = [];

  @override
  void initState() {
    super.initState();
    _initializeCounters();
    _loadProgress();
  }

  void _initializeCounters() {
    int totalAdhkar = 0;
    for (var category in SpecialAdhkarData.categories) {
      totalAdhkar += (category['adhkar'] as List).length;
    }
    _counters.addAll(List.filled(totalAdhkar, 0));
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStrings = prefs.getStringList('special_adhkar_counters');
    if (savedStrings != null && savedStrings.length == _counters.length) {
      setState(() {
        for (int i = 0; i < savedStrings.length; i++) {
          _counters[i] = int.tryParse(savedStrings[i]) ?? 0;
        }
      });
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final strings = _counters.map((c) => c.toString()).toList();
    await prefs.setStringList('special_adhkar_counters', strings);
  }

  void _incrementCounter(int index, int targetCount) {
    setState(() {
      if (_counters[index] < targetCount) {
        _counters[index]++;
      }
    });
    _saveProgress();
    HapticFeedback.lightImpact();
  }

  void _resetCounter(int index) {
    setState(() {
      _counters[index] = 0;
    });
    _saveProgress();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'أذكار مختارة',
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
          itemCount: SpecialAdhkarData.categories.length,
          itemBuilder: (context, categoryIndex) {
            final category = SpecialAdhkarData.categories[categoryIndex];
            return _buildCategoryCard(category, categoryIndex);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int categoryIndex) {
    final adhkar = category['adhkar'] as List<Map<String, dynamic>>;
    final color = Color(int.parse(category['color'] as String));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Text(
                  category['icon'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // الأذكار
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: adhkar.asMap().entries.map((entry) {
                final adhkarIndex = _getAdhkarIndex(categoryIndex, entry.key);
                final dhikr = entry.value;
                final currentCount = _counters[adhkarIndex];
                final targetCount = dhikr['count'] as int;
                final isCompleted = currentCount >= targetCount;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF4CAF50)
                          : color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نص الذكر
                      Text(
                        dhikr['text'] as String,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 10),

                      // الوصف
                      if (dhikr['description'] != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            dhikr['description'] as String,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      const SizedBox(height: 12),

                      // العداد والأزرار
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // العداد
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF4CAF50)
                                  : color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$currentCount / $targetCount',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // الأزرار
                          Row(
                            children: [
                              if (!isCompleted)
                                GestureDetector(
                                  onTap: () => _incrementCounter(
                                      adhkarIndex, targetCount),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [color, color.withOpacity(0.7)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'اضغط',
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _resetCounter(adhkarIndex),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _getAdhkarIndex(int categoryIndex, int adhkarInCategory) {
    int index = 0;
    for (int i = 0; i < categoryIndex; i++) {
      index += (SpecialAdhkarData.categories[i]['adhkar'] as List).length;
    }
    return index + adhkarInCategory;
  }
}