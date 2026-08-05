import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import 'surah_view_screen.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({Key? key}) : super(key: key);

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  String _searchQuery = '';

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
            colors: [Color(0xFF1A1F3A), Color(0xFF0D1B2A), Color(0xFF0A0E27)],
          ),
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text('القرآن الكريم',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A0E27))),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF0A0E27).withOpacity(0.3),
                            width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                    hintStyle: TextStyle(color: goldColor.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: goldColor),
                    filled: true,
                    fillColor: const Color(0xFF162447).withOpacity(0.6),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: goldColor.withOpacity(0.4))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: goldColor.withOpacity(0.4))),
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
                        color: const Color(0xFF162447).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: goldColor.withOpacity(0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SurahViewScreen(
                                      surahNumber: surahNumber)));
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
                                  color: goldColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Center(
                            child: Text(_toArabicNumber(surahNumber),
                                style: const TextStyle(
                                    color: goldColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ),
                        ),
                        title: Text(surahName,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        subtitle: Text(
                          '${quran.getPlaceOfRevelation(surahNumber) == "Makkah" ? "مكية" : "مدنية"} • ${_toArabicNumber(quran.getVerseCount(surahNumber))} آية',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7)),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.2),
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
