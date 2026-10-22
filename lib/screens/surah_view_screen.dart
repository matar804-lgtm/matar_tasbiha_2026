import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../services/bookmark_manager.dart';

class SurahViewScreen extends StatefulWidget {
  final int surahNumber;
  final int? scrollToAyah;

  const SurahViewScreen({
    super.key,
    required this.surahNumber,
    this.scrollToAyah,
  });

  @override
  State<SurahViewScreen> createState() => _SurahViewScreenState();
}

class _SurahViewScreenState extends State<SurahViewScreen> {
  final Set<int> _bookmarkedAyahs = <int>{};

  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> _ayahKeys = <int, GlobalKey>{};

  bool _isLoading = true;
  bool _isBookmarkLoading = false;

  static const Color _backgroundColor = Color(0xFF0A201A);
  static const Color _appBarColor = Color(0xFF1B342B);
  static const Color _cardColor = Color(0xFF132A22);
  static const Color _goldColor = Color(0xFFC9B896);
  static const Color _bookmarkColor = Color(0xFFD4AF37);
  static const Color _textColor = Color(0xFFF0E0B5);

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _getAyahKey(int ayahNumber) {
    return _ayahKeys.putIfAbsent(
      ayahNumber,
      GlobalKey.new,
    );
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await BookmarkManager.getBookmarks();

      if (!mounted) return;

      final loadedBookmarks = <int>{};

      for (final bookmark in bookmarks) {
        final bookmarkSurah = bookmark['surahNumber'];
        final bookmarkAyah = bookmark['ayahNumber'];

        final surahNumber = bookmarkSurah is num
            ? bookmarkSurah.toInt()
            : int.tryParse(bookmarkSurah?.toString() ?? '');

        final ayahNumber = bookmarkAyah is num
            ? bookmarkAyah.toInt()
            : int.tryParse(bookmarkAyah?.toString() ?? '');

        if (surahNumber == widget.surahNumber && ayahNumber != null) {
          loadedBookmarks.add(ayahNumber);
        }
      }

      setState(() {
        _bookmarkedAyahs
          ..clear()
          ..addAll(loadedBookmarks);

        _isLoading = false;
      });

      if (widget.scrollToAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToAyah(widget.scrollToAyah!);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'حدث خطأ أثناء تحميل الإشارات المرجعية',
        isError: true,
      );
    }
  }

  Future<void> _scrollToAyah(int ayahNumber) async {
    if (!_scrollController.hasClients) return;

    final ayahCount = quran.getVerseCount(widget.surahNumber);

    if (ayahCount <= 0) return;

    final safeAyahNumber = ayahNumber.clamp(1, ayahCount);

    final key = _getAyahKey(safeAyahNumber);
    final targetContext = key.currentContext;

    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    // في حال لم يتم إنشاء الـ widget المطلوب بعد،
    // نستخدم تقديراً تقريبياً للوصول إلى المنطقة المطلوبة.
    final estimatedOffset = (safeAyahNumber - 1) * 180.0;

    final maxScroll = _scrollController.position.maxScrollExtent;

    final targetOffset = estimatedOffset.clamp(
      0.0,
      maxScroll,
    );

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // نحاول مرة أخرى بعد اكتمال عملية التمرير.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = key.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
      }
    });
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    if (_isBookmarkLoading) return;

    final surahName = quran.getSurahName(widget.surahNumber);
    final ayahText = quran.getVerse(
      widget.surahNumber,
      ayahNumber,
    );

    final isCurrentlyBookmarked = _bookmarkedAyahs.contains(ayahNumber);

    setState(() {
      _isBookmarkLoading = true;
    });

    try {
      if (isCurrentlyBookmarked) {
        await BookmarkManager.removeBookmark(
          surahNumber: widget.surahNumber,
          ayahNumber: ayahNumber,
        );

        if (!mounted) return;

        setState(() {
          _bookmarkedAyahs.remove(ayahNumber);
        });

        _showMessage(
          'تم حذف الإشارة المرجعية',
        );
      } else {
        await BookmarkManager.addBookmark(
          surahName: surahName,
          surahNumber: widget.surahNumber,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
        );

        if (!mounted) return;

        setState(() {
          _bookmarkedAyahs.add(ayahNumber);
        });

        _showMessage(
          'تم حفظ الإشارة للآية ${_toArabicNumber(ayahNumber)}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'عذراً، حدث خطأ أثناء حفظ الإشارة المرجعية',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBookmarkLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 15,
            ),
          ),
          backgroundColor: isError ? Colors.redAccent : _appBarColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String _toArabicNumber(int number) {
    const arabicNumbers = <String>[
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
          (digit) => arabicNumbers[int.parse(digit)],
        )
        .join();
  }

  Widget _buildAyahCard({
    required int ayahNumber,
    required String ayahText,
  }) {
    final isBookmarked = _bookmarkedAyahs.contains(ayahNumber);

    return Card(
      key: _getAyahKey(ayahNumber),
      color: _cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isBookmarked
              ? _bookmarkColor
              : _goldColor.withValues(alpha: 0.30),
          width: isBookmarked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _goldColor.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'آية ${_toArabicNumber(ayahNumber)}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      color: _goldColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isBookmarked
                      ? 'حذف الإشارة المرجعية'
                      : 'حفظ الإشارة المرجعية',
                  onPressed: _isBookmarkLoading
                      ? null
                      : () => _toggleBookmark(
                            ayahNumber,
                          ),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey<bool>(
                        isBookmarked,
                      ),
                      color: isBookmarked ? _bookmarkColor : _goldColor,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ayahText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: _textColor,
                fontSize: 20,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _goldColor,
      ),
    );
  }

  Widget _buildAyahs() {
    final ayahCount = quran.getVerseCount(widget.surahNumber);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        32,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: ayahCount,
      itemBuilder: (context, index) {
        final ayahNumber = index + 1;

        final ayahText = quran.getVerse(
          widget.surahNumber,
          ayahNumber,
        );

        return _buildAyahCard(
          ayahNumber: ayahNumber,
          ayahText: ayahText,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahName = quran.getSurahName(widget.surahNumber);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _appBarColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          surahName,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'Amiri',
            color: _goldColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          tooltip: 'رجوع',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _goldColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home_rounded,
              color: _goldColor,
            ),
            onPressed: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildAyahs(),
    );
  }
}
