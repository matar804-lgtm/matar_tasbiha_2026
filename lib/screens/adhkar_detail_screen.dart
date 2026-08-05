import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> duas;
  final int categoryIndex;
  final Color color;

  const AdhkarDetailScreen({
    Key? key,
    required this.title,
    required this.duas,
    required this.categoryIndex,
    required this.color,
  }) : super(key: key);

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  final List<int> _counters = [];

  @override
  void initState() {
    super.initState();
    _counters.addAll(List.filled(widget.duas.length, 0));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStrings =
        prefs.getStringList('adhkar_counters_${widget.categoryIndex}');
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
    await prefs.setStringList(
        'adhkar_counters_${widget.categoryIndex}', strings);
  }

  void _increment(int index, int target) {
    setState(() {
      if (_counters[index] < target) {
        _counters[index]++;
      }
    });
    _saveProgress();
    HapticFeedback.lightImpact();
  }

  void _reset(int index) {
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
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.duas.length,
        itemBuilder: (context, index) {
          final dua = widget.duas[index];
          final currentCount = _counters[index];
          final targetCount = dua['count'] as int;
          final isCompleted = currentCount >= targetCount;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : widget.color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua['content']
                      as String, // ✅ تم التعديل هنا لتطابق ملف البيانات
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: Color(0xFFD4AF37),
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (dua['reference'] != null &&
                    (dua['reference'] as String).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.color.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: widget.color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dua['reference']
                                as String, // ✅ تم التعديل هنا لتطابق ملف البيانات
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF4CAF50)
                            : widget.color,
                        borderRadius: BorderRadius.circular(18),
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
                    Row(
                      children: [
                        if (!isCompleted)
                          GestureDetector(
                            onTap: () => _increment(index, targetCount),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  widget.color,
                                  widget.color.withOpacity(0.7)
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'اضغط',
                                style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _reset(index),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.refresh,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
