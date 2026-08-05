import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'surah_detail_screen.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String _searchQuery = '';

  String _toArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((c) => arabicNumbers[int.parse(c)])
        .join();
  }

  void _showBookmarksModal() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ الإصلاح الجذري: التحقق من mounted فوراً بعد أي await
    if (!mounted) return;

    final String? bookmarksString = prefs.getString('quran_bookmarks_list');
    List<Map<String, dynamic>> bookmarks = [];

    if (bookmarksString != null) {
      final List<dynamic> decoded = jsonDecode(bookmarksString);
      bookmarks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF162447),
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
            const Text('الإشارات المرجعية المحفوظة',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (bookmarks.isEmpty)
              const Text('لا توجد إشارات مرجعية محفوظة',
                  style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 16, color: Colors.white70))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final b = bookmarks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.bookmark,
                            color: Color(0xFFD4AF37)),
                        title: Text(
                            'سورة ${quran.getSurahNameArabic(b['surah'])} - آية ${_toArabicNumber(b['ayah'])}',
                            style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: Colors.white)),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () async {
                              setState(() => bookmarks.removeAt(index));
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('quran_bookmarks_list',
                                  jsonEncode(bookmarks));

                              if (mounted) {
                                Navigator.pop(context);
                                _showBookmarksModal();
                              }
                            }),
                        onTap: () {
                          // ✅ الإصلاح: حماية الـ Context داخل الدالة الـ async
                          if (!mounted) return;
                          Navigator.pop(context);
                          if (!mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                      surahNumber: b['surah'],
                                      startAyah: b['ayah'])));
                        },
                      ),
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
    const Color goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1F3A),
                Color(0xFF0D1B2A),
                Color(0xFF0A0E27)
              ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Color(0xFF0A0E27)),
                            onPressed: () => Navigator.pop(context)),
                        const Expanded(
                            child: Text('القرآن الكريم',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A0E27)))),
                        IconButton(
                            icon: const Icon(Icons.bookmarks,
                                color: Color(0xFF0A0E27)),
                            tooltip: 'الإشارات المرجعية',
                            onPressed: _showBookmarksModal),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF0A0E27)
                                  .withValues(alpha: 0.3),
                              width: 2),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A0E27),
                              letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: goldColor, fontSize: 16),
                  cursorColor: goldColor,
                  decoration: InputDecoration(
                    hintText: 'البحث عن سورة...',
                    hintStyle:
                        TextStyle(color: goldColor.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search, color: goldColor),
                    filled: true,
                    fillColor: const Color(0xFF162447).withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: goldColor.withValues(alpha: 0.4))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: goldColor.withValues(alpha: 0.4))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: goldColor, width: 2)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 114,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (context, index) {
                    int surahNumber = index + 1;
                    String surahName = quran.getSurahNameArabic(surahNumber);

                    if (_searchQuery.isNotEmpty &&
                        !surahName.contains(_searchQuery)) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF162447).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: goldColor.withValues(alpha: 0.4),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SurahDetailScreen(
                                        surahNumber: surahNumber)));
                          }
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: goldColor, width: 2),
                            color: const Color(0xFF1A1F3A),
                            boxShadow: [
                              BoxShadow(
                                  color: goldColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Center(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(_toArabicNumber(surahNumber),
                                  style: const TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                          ),
                        ),
                        title: Text(surahName,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        subtitle: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            '${quran.getPlaceOfRevelation(surahNumber) == "Mecca" ? "مكية" : "مدنية"} • ${_toArabicNumber(quran.getVerseCount(surahNumber))} آية',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: goldColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              color: goldColor, size: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
