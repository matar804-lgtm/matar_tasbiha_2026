import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;
import 'dart:convert';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int startAyah;
  final String? surahName;

  const SurahDetailScreen({
    Key? key,
    required this.surahNumber,
    this.startAyah = 1,
    this.surahName,
  }) : super(key: key);

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 24;
  String _fontFamily = 'Amiri';
  late int _verseCount;
  final ScrollController _scrollController = ScrollController();
  int _currentAyah = 1;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _verseCount = quran.getVerseCount(widget.surahNumber);
    _loadSettings();
    _loadBookmarks();
    _currentAyah = widget.startAyah;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('quran_font_size') ?? 24;
      _fontFamily = prefs.getString('quran_font_family') ?? 'Amiri';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_font_size', _fontSize);
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarksString = prefs.getString('quran_bookmarks_list');
    if (bookmarksString != null) {
      final List<dynamic> decoded = jsonDecode(bookmarksString);
      setState(() {
        _bookmarks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _addBookmark(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final newBookmark = {
      'surah': surah,
      'ayah': ayah,
      'time': DateTime.now().millisecondsSinceEpoch
    };

    _bookmarks.removeWhere((b) => b['surah'] == surah && b['ayah'] == ayah);
    _bookmarks.insert(0, newBookmark);

    if (_bookmarks.length > 10) {
      _bookmarks.removeLast();
    }

    await prefs.setString('quran_bookmarks_list', jsonEncode(_bookmarks));
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.bookmark, color: Colors.amber, size: 24),
            const SizedBox(width: 10),
            Text('تم حفظ الإشارة المرجعية',
                style: TextStyle(fontFamily: _fontFamily, fontSize: 16))
          ]),
          backgroundColor: const Color(0xFF009688),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  // ✅ دالة تحويل أرقام آمنة ودقيقة
  String _toArabicNumber(dynamic input) {
    const englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String text = input.toString();
    englishToArabic.forEach((en, ar) {
      text = text.replaceAll(en, ar);
    });

    return text;
  }

  void _showBookmarksModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF009688),
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
            const Text('الإشارات المرجعية (آخر 10)',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_bookmarks.isEmpty)
              const Text('لا توجد إشارات مرجعية محفوظة',
                  style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 16, color: Colors.white70))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final b = _bookmarks[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.amber),
                      title: Text(
                          'سورة ${quran.getSurahNameArabic(b['surah'])} - آية ${_toArabicNumber(b['ayah'])}',
                          style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              color: Colors.white)),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () async {
                            setState(() => _bookmarks.removeAt(index));
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                'quran_bookmarks_list', jsonEncode(_bookmarks));
                          }),
                      onTap: () {
                        Navigator.pop(context);
                        if (b['surah'] != widget.surahNumber) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                      surahNumber: b['surah'],
                                      startAyah: b['ayah'])));
                        } else {
                          setState(() => _currentAyah = b['ayah']);
                        }
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

  @override
  Widget build(BuildContext context) {
    final displaySurahName =
        widget.surahName ?? quran.getSurahNameArabic(widget.surahNumber);
    final isMeccan = quran.getPlaceOfRevelation(widget.surahNumber) == 'Makkah';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF009688),
          title: Text('سورة $displaySurahName',
              style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  if (_fontSize > 16) {
                    setState(() => _fontSize -= 2);
                    _saveSettings();
                  }
                }),
            Center(
              child: Text('${_fontSize.toInt()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  if (_fontSize < 40) {
                    setState(() => _fontSize += 2);
                    _saveSettings();
                  }
                }),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.bookmarks, color: Colors.white),
                onPressed: _showBookmarksModal),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1B5E20),
                        Color(0xFF2E7D32),
                        Color(0xFF43A047)
                      ]),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFD4AF37), width: 3))),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 2),
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(0.1)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoBadge(
                              'رقمها: ${_toArabicNumber(widget.surahNumber)}',
                              Colors.amber),
                          const SizedBox(width: 10),
                          _buildInfoBadge(
                              'آياتها: ${_toArabicNumber(_verseCount)}',
                              Colors.lightBlue),
                          const SizedBox(width: 10),
                          _buildInfoBadge(
                              isMeccan ? 'مكية' : 'مدنية', Colors.green),
                        ]),
                  ),
                  const SizedBox(height: 15),
                  if (widget.surahNumber != 9 && widget.surahNumber != 1)
                    Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5DC),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      GestureDetector(
                        onLongPress: () =>
                            _addBookmark(widget.surahNumber, _currentAyah),
                        child: Text.rich(
                          TextSpan(children: _buildAyahSpans()),
                          style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: _fontSize,
                              color: Colors.black87,
                              height: 2.3,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                  color: Color(0xFF009688),
                  border: Border(
                      top: BorderSide(color: Color(0xFFD4AF37), width: 2))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.surahNumber > 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(
                                    surahNumber: widget.surahNumber - 1,
                                    startAyah: 1)));
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text('السابق',
                          style:
                              TextStyle(fontFamily: _fontFamily, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF009688),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )
                  else
                    const SizedBox(width: 100),
                  Text(
                      '${_toArabicNumber(_currentAyah)} / ${_toArabicNumber(_verseCount)}',
                      style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  if (widget.surahNumber < 114)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(
                                    surahNumber: widget.surahNumber + 1,
                                    startAyah: 1)));
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('التالي',
                          style:
                              TextStyle(fontFamily: _fontFamily, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF009688),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )
                  else
                    const SizedBox(width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ بناء الآيات: كل سورة تبدأ من 1 بشكل مستقل تماماً
  List<InlineSpan> _buildAyahSpans() {
    List<InlineSpan> spans = [];
    for (int i = 1; i <= _verseCount; i++) {
      final verseText = quran.getVerse(widget.surahNumber, i);

      // ✅ الحل الجذري: نمرر رقم الآية المحلي (i) مباشرة للدالة
      // هذا يضمن أن الرمز الزخرفي سيظهر دائماً بداية من ١ حتى نهاية السورة
      final String verseSymbol = quran.getVerseEndSymbol(i);

      final isCurrent = _currentAyah == i;

      // 1. نص الآية
      spans.add(TextSpan(
        text: '$verseText ',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize,
          color: Colors.black87,
          backgroundColor:
              isCurrent ? Colors.amber.withOpacity(0.3) : Colors.transparent,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            setState(() => _currentAyah = i);
            HapticFeedback.lightImpact();
          },
      ));

      // 2. رمز نهاية الآية المدمج مع الرقم المحلي الصحيح
      spans.add(TextSpan(
        text: '$verseSymbol ',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize * 0.9,
          color: isCurrent ? Colors.amber[900] : const Color(0xFF009688),
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            setState(() => _currentAyah = i);
            HapticFeedback.lightImpact();
          },
      ));
    }
    return spans;
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5)),
      child: Text(text,
          style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold)),
    );
  }
}
