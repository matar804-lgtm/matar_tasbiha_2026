import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

import 'surah_detail_screen.dart';
import '../services/surah_revelation_service.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String _searchQuery = '';

  String _toArabicNumber(int number) {
    const List<String> arabicNumbers = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ];

    return number
        .toString()
        .split('')
        .map(
          (c) => arabicNumbers[int.parse(c)],
        )
        .join();
  }

  Future<void> _showBookmarksModal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    final String? bookmarksString = prefs.getString('quran_bookmarks_list');

    List<Map<String, dynamic>> bookmarks = [];

    if (bookmarksString != null && bookmarksString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(bookmarksString);

        bookmarks = decoded
            .map(
              (e) => Map<String, dynamic>.from(e),
            )
            .toList();
      } catch (e) {
        debugPrint(
          'Failed to decode Quran bookmarks: $e',
        );
      }
    }

    final ThemeData theme = Theme.of(context);

    final ColorScheme scheme = theme.colorScheme;

    final bool isDark = theme.brightness == Brightness.dark;

    final Color goldColor =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF9A7412);

    final Color sheetColor = isDark ? const Color(0xFF162447) : Colors.white;

    final Color itemColor =
        isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF4F7F5);

    final Color primaryText = scheme.onSurface;

    final Color secondaryText = scheme.onSurface.withValues(
      alpha: 0.68,
    );

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: secondaryText,
                    borderRadius: BorderRadius.circular(
                      3,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'الإشارات المرجعية المحفوظة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (bookmarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: Text(
                      'لا توجد إشارات مرجعية محفوظة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: secondaryText,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: bookmarks.length,
                      itemBuilder: (itemContext, index) {
                        final Map<String, dynamic> bookmark = bookmarks[index];

                        final int surah = bookmark['surah'] as int;

                        final int ayah = bookmark['ayah'] as int;

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            color: itemColor,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            border: Border.all(
                              color: goldColor.withValues(
                                alpha: 0.30,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.bookmark_rounded,
                              color: goldColor,
                            ),
                            title: Text(
                              'سورة '
                              '${quran.getSurahNameArabic(surah)}'
                              ' - آية '
                              '${_toArabicNumber(ayah)}',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                setState(
                                  () {
                                    bookmarks.removeAt(
                                      index,
                                    );
                                  },
                                );

                                final SharedPreferences updatedPrefs =
                                    await SharedPreferences.getInstance();

                                await updatedPrefs.setString(
                                  'quran_bookmarks_list',
                                  jsonEncode(
                                    bookmarks,
                                  ),
                                );

                                if (!mounted) {
                                  return;
                                }

                                final NavigatorState modalNavigator =
                                    Navigator.of(
                                  modalContext,
                                );

                                modalNavigator.pop();

                                await _showBookmarksModal();
                              },
                            ),
                            onTap: () {
                              Navigator.of(
                                itemContext,
                              ).pop();

                              Navigator.of(
                                context,
                              ).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                    surahNumber: surah,
                                    startAyah: ayah,
                                  ),
                                ),
                              );
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
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme scheme = theme.colorScheme;

    final bool isDark = theme.brightness == Brightness.dark;

    final Color goldColor =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF9A7412);

    final Color pageBackground = theme.scaffoldBackgroundColor;

    final Color headerText = isDark ? const Color(0xFF0A0E27) : Colors.white;

    final Color headerStart =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF1B342B);

    final Color headerEnd =
        isDark ? const Color(0xFFB8860B) : const Color(0xFF2A4A3D);

    final Color searchBackground =
        isDark ? const Color(0xFF162447) : Colors.white;

    final Color cardBackground =
        isDark ? const Color(0xFF162447) : Colors.white;

    final Color cardBorder = isDark
        ? goldColor.withValues(
            alpha: 0.40,
          )
        : const Color(0xFFB9C8C0);

    final Color primaryText = scheme.onSurface;

    final Color secondaryText = scheme.onSurface.withValues(
      alpha: 0.68,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1A1F3A),
                    Color(0xFF0D1B2A),
                    Color(0xFF0A0E27),
                  ]
                : const [
                    Color(0xFFF7FAF8),
                    Color(0xFFEAF1ED),
                    Color(0xFFF5F8F6),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      headerStart,
                      headerEnd,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(
                      30,
                    ),
                    bottomRight: Radius.circular(
                      30,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: headerText,
                          ),
                          onPressed: () => Navigator.pop(
                            context,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'القرآن الكريم',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: headerText,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.bookmarks_rounded,
                            color: headerText,
                          ),
                          tooltip: 'الإشارات المرجعية',
                          onPressed: _showBookmarksModal,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: headerText.withValues(
                            alpha: 0.30,
                          ),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: headerText,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(
                  16,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  style: TextStyle(
                    color: goldColor,
                    fontFamily: 'Amiri',
                    fontSize: 16,
                  ),
                  cursorColor: goldColor,
                  decoration: InputDecoration(
                    hintText: 'البحث عن سورة...',
                    hintStyle: TextStyle(
                      color: goldColor.withValues(
                        alpha: 0.60,
                      ),
                      fontFamily: 'Amiri',
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: goldColor,
                    ),
                    filled: true,
                    fillColor: searchBackground.withValues(
                      alpha: isDark ? 0.70 : 1.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      borderSide: BorderSide(
                        color: goldColor.withValues(
                          alpha: 0.30,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      borderSide: BorderSide(
                        color: goldColor.withValues(
                          alpha: 0.30,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      borderSide: BorderSide(
                        color: goldColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 114,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemBuilder: (context, index) {
                    final int surahNumber = index + 1;

                    final String surahName = quran.getSurahNameArabic(
                      surahNumber,
                    );

                    if (_searchQuery.isNotEmpty &&
                        !surahName.contains(
                          _searchQuery,
                        )) {
                      return const SizedBox.shrink();
                    }

                    final String revelation =
                        SurahRevelationService.labelAr(surahNumber) ?? '';

                    final String verseCount = _toArabicNumber(
                      quran.getVerseCount(
                        surahNumber,
                      ),
                    );

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cardBackground.withValues(
                          alpha: isDark ? 0.60 : 0.96,
                        ),
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        border: Border.all(
                          color: cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 6,
                              offset: const Offset(
                                0,
                                3,
                              ),
                            ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goldColor,
                              width: 2,
                            ),
                            color: isDark
                                ? const Color(
                                    0xFF1A1F3A,
                                  )
                                : const Color(
                                    0xFFEAF1ED,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                _toArabicNumber(
                                  surahNumber,
                                ),
                                style: TextStyle(
                                  color: goldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          surahName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        subtitle: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            '$revelation • '
                            '$verseCount آية',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14,
                              color: secondaryText,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(
                            8,
                          ),
                          decoration: BoxDecoration(
                            color: goldColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: goldColor,
                            size: 16,
                          ),
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
