import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreenNew extends StatefulWidget {
  const TasbihScreenNew({Key? key}) : super(key: key);

  @override
  State<TasbihScreenNew> createState() => _TasbihScreenNewState();
}

class _TasbihScreenNewState extends State<TasbihScreenNew> {
  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  int _currentDhikrIndex = 0;

  final List<Map<String, dynamic>> _adhkar = [
    {'text': 'سُبْحَانَ اللَّهِ', 'target': 33},
    {'text': 'الْحَمْدُ لِلَّهِ', 'target': 33},
    {'text': 'اللَّهُ أَكْبَرُ', 'target': 34},
    {'text': 'لَا إِلَهَ إِلَّا اللَّهُ', 'target': 100},
    {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'target': 100},
    {'text': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ', 'target': 100},
    {'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'target': 100},
    {'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 'target': 100},
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      _target = prefs.getInt('tasbih_target') ?? 33;
      _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
      _currentDhikrIndex = prefs.getInt('current_dhikr_index') ?? 0;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_target', _target);
    await prefs.setInt('tasbih_total_count', _totalCount);
    await prefs.setInt('current_dhikr_index', _currentDhikrIndex);
  }

  void _incrementCount() {
    setState(() {
      _count++;
      _totalCount++;
      if (_count >= _target) {
        _currentDhikrIndex = (_currentDhikrIndex + 1) % _adhkar.length;
        _target = _adhkar[_currentDhikrIndex]['target'] as int;
        _count = 0;
      }
    });
    _saveState();
    HapticFeedback.lightImpact();
  }

  void _resetCount() {
    setState(() => _count = 0);
    _saveState();
  }

  void _resetAll() {
    setState(() {
      _count = 0;
      _totalCount = 0;
    });
    _saveState();
  }

  String _toArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((c) => arabicNumbers[int.parse(c)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _incrementCount,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0a0e27),
                  Color(0xFF1a1f3a),
                  Color(0xFF0d1b2a)
                ]),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context)),
                      const Text('التسبيح',
                          style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.settings,
                              color: Color(0xFFD4AF37)),
                          onPressed: _showSettings),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // ✅ تم الإصلاح: withOpacity -> withValues
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          // ✅ تم الإصلاح: withOpacity -> withValues
                          color:
                              const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _adhkar[_currentDhikrIndex]['text'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                    boxShadow: [
                      BoxShadow(
                          // ✅ تم الإصلاح: withOpacity -> withValues
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                          blurRadius: 30,
                          spreadRadius: 10)
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_toArabicNumber(_count),
                          style: const TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Amiri')),
                      const SizedBox(height: 10),
                      Text('من ${_toArabicNumber(_target)}',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontFamily: 'Amiri')),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PopupMenuButton<String>(
                        color: const Color(0xFF1a1f3a),
                        onSelected: (value) {
                          if (value == 'reset') _resetCount();
                          if (value == 'resetAll') _resetAll();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'reset',
                              child: Text('تصفير العداد',
                                  style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: Colors.white))),
                          const PopupMenuItem(
                              value: 'resetAll',
                              child: Text('تصفير الكل',
                                  style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: Colors.white))),
                        ],
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                                // ✅ تم الإصلاح: withOpacity -> withValues
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                    // ✅ تم الإصلاح: withOpacity -> withValues
                                    color:
                                        Colors.white.withValues(alpha: 0.3))),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✅ تم الإصلاح: إضافة const
                                  Icon(Icons.refresh,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('تصفير',
                                      style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 16,
                                          color: Colors.white))
                                ])),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                              // ✅ تم الإصلاح: withOpacity -> withValues
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  // ✅ تم الإصلاح: withOpacity -> withValues
                                  color: Colors.white.withValues(alpha: 0.3))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.analytics,
                                color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 8),
                            Text('الإجمالي: ${_toArabicNumber(_totalCount)}',
                                style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16,
                                    color: Colors.white))
                          ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 20),
            const Text('إعدادات التسبيح',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.format_list_numbered,
                    color: Color(0xFFD4AF37)),
                title: const Text('مجموعات التسبيح',
                    style: TextStyle(color: Colors.white, fontFamily: 'Amiri')),
                onTap: () {
                  Navigator.pop(context);
                  _showDhikrSelector();
                }),
            const Divider(color: Color(0xFFD4AF37)),
            ListTile(
                leading: const Icon(Icons.flag, color: Color(0xFFD4AF37)),
                title: const Text('تغيير الهدف',
                    style: TextStyle(color: Colors.white, fontFamily: 'Amiri')),
                subtitle: Text('الهدف الحالي: $_target',
                    style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Amiri',
                        fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _showTargetSelector();
                }),
            const Divider(color: Color(0xFFD4AF37)),
            ListTile(
                leading: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
                title: const Text('تصفير العداد',
                    style: TextStyle(color: Colors.white, fontFamily: 'Amiri')),
                onTap: () {
                  Navigator.pop(context);
                  _resetCount();
                }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDhikrSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 20),
            const Text('اختر الذكر',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _adhkar.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentDhikrIndex;
                  return ListTile(
                    leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.white54),
                    title: Text(_adhkar[index]['text'] as String,
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : Colors.white)),
                    onTap: () {
                      setState(() {
                        _currentDhikrIndex = index;
                        _target = _adhkar[index]['target'] as int;
                        _count = 0;
                      });
                      _saveState();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2)),
        title: const Text('اختر الهدف',
            style: TextStyle(fontFamily: 'Amiri', color: Color(0xFFD4AF37))),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [33, 99, 100, 500, 1000].map((target) {
              return ListTile(
                  title: Text('$target مرة',
                      // ✅ تم الإصلاح: إضافة const لـ TextStyle
                      style: const TextStyle(
                          fontFamily: 'Amiri', color: Colors.white)),
                  trailing: target == _target
                      // ✅ تم الإصلاح: إضافة const لـ Icon
                      ? const Icon(Icons.check, color: Color(0xFFD4AF37))
                      : null,
                  onTap: () {
                    setState(() {
                      _target = target;
                      _count = 0;
                    });
                    _saveState();
                    Navigator.pop(context);
                  });
            }).toList()),
      ),
    );
  }
}
