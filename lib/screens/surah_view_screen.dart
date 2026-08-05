import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import '../services/bookmark_manager.dart';

class SurahViewScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyah;

  const SurahViewScreen({
    Key? key,
    required this.surahNumber,
    this.initialAyah,
  }) : super(key: key);

  @override
  State<SurahViewScreen> createState() => _SurahViewScreenState();
}

class _SurahViewScreenState extends State<SurahViewScreen> {
  double _fontSize = 26.0;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  String _toArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((c) => arabicNumbers[int.parse(c)])
        .join();
  }

  @override
  void initState() {
    super.initState();
    _scrollToInitialAyah();
  }

  void _scrollToInitialAyah() {
    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _verseKeys[widget.initialAyah];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveBookmark(int ayahNumber) async {
    String surahName = quran.getSurahNameArabic(widget.surahNumber);

    final bookmark = BookmarkManager.createBookmark(
      surahNumber: widget.surahNumber,
      ayahNumber: ayahNumber,
      surahName: surahName,
    );

    final success = await BookmarkManager.addBookmark(bookmark);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'تم حفظ العلامة: سورة $surahName - آية ${_toArabicNumber(ayahNumber)}',
                  style: const TextStyle(fontFamily: 'Amiri'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD4AF37),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'عذراً، الحد الأقصى للعلامات المرجعية هو 10 فقط',
              style: TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalVerses = quran.getVerseCount(widget.surahNumber);
    String surahName = quran.getSurahNameArabic(widget.surahNumber);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 2,
        centerTitle: true,
        // زر الرجوع باللون الذهبي
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'سورة $surahName',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize + 2).clamp(20.0, 45.0)),
          ),
          IconButton(
            icon: const Icon(Icons.remove, color: Color(0xFFD4AF37)),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize - 2).clamp(20.0, 45.0)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_quran.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                color: const Color(0xFF162447).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/quran_pattern.png'),
                      opacity: 0.05,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // عنوان السورة المزخرف
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1F3A),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color:
                                      const Color(0xFFD4AF37).withOpacity(0.6),
                                  width: 1.5),
                            ),
                            child: Text(
                              surahName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // البسملة
                          if (widget.surahNumber != 9)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: _fontSize + 2,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4AF37),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),

                          // الآيات مع إمكانية الضغط المطول
                          _buildVersesWithLongPress(totalVerses),

                          const SizedBox(height: 30),
                          Icon(
                            Icons.hexagon,
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            size: 30,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════ بناء الآيات مع الضغط المطول ═══════════════
  Widget _buildVersesWithLongPress(int totalVerses) {
    List<Widget> verseWidgets = [];

    for (int i = 1; i <= totalVerses; i++) {
      String verseText = quran.getVerse(
        widget.surahNumber,
        i,
        verseEndSymbol: false,
      );

      // إنشاء مفتاح فريد لكل آية للتمرير إليها
      final verseKey = GlobalKey();
      _verseKeys[i] = verseKey;

      verseWidgets.add(
        KeyedSubtree(
          key: verseKey,
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _saveBookmark(i);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      verseText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: _fontSize,
                        height: 2.6,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFD4AF37), width: 1.5),
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                    ),
                    child: Text(
                      _toArabicNumber(i),
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: verseWidgets,
    );
  }
}
