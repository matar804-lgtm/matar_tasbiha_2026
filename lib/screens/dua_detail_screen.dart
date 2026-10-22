import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuaDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final String virtue;
  final int repeatCount;
  final String source;

  const DuaDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.virtue,
    required this.repeatCount,
    required this.source,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen>
    with WidgetsBindingObserver {
  late int _remainingCount;
  late int _initialCount;

  Timer? _midnightTimer;

  bool _loading = true;
  bool _resetInProgress = false;
  bool _disposed = false;

  String get _duaId {
    final String title = widget.title.trim();

    return title.isEmpty ? 'dua_unknown' : title;
  }

  String get _counterKey => 'dua_counter_$_duaId';

  String get _dateKey => 'dua_counter_date_$_duaId';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initialCount = widget.repeatCount > 0 ? widget.repeatCount : 1;

    _remainingCount = _initialCount;

    _initialize();
  }

  @override
  void dispose() {
    _disposed = true;

    WidgetsBinding.instance.removeObserver(this);

    _midnightTimer?.cancel();
    _midnightTimer = null;

    super.dispose();
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _checkForNewDay();
      _scheduleMidnightCheck();
    }
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initialize() async {
    await _checkForNewDay();

    if (!mounted || _disposed) {
      return;
    }

    setState(() {
      _loading = false;
    });

    _scheduleMidnightCheck();
  }

  // ============================================================
  // DATE
  // ============================================================

  String _todayKey() {
    final DateTime now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // DAILY RESET CHECK
  // ============================================================

  Future<void> _checkForNewDay() async {
    if (_resetInProgress || _disposed) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_disposed) {
      return;
    }

    final String today = _todayKey();

    final String? savedDate = prefs.getString(_dateKey);

    // أول مرة يفتح فيها هذا الدعاء.
    if (savedDate == null) {
      await _loadCounter(prefs);

      if (_disposed) {
        return;
      }

      await prefs.setString(
        _dateKey,
        today,
      );

      return;
    }

    // نفس اليوم.
    if (savedDate == today) {
      await _loadCounter(prefs);
      return;
    }

    // يوم جديد.
    await _resetForNewDay(
      prefs: prefs,
      today: today,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadCounter(
    SharedPreferences prefs,
  ) async {
    final int? savedCount = prefs.getInt(_counterKey);

    if (savedCount == null) {
      return;
    }

    final int safeCount = savedCount.clamp(
      0,
      _initialCount,
    );

    _remainingCount = safeCount;

    if (mounted && !_disposed) {
      setState(() {});
    }
  }

  // ============================================================
  // NEW DAY RESET
  // ============================================================

  Future<void> _resetForNewDay({
    required SharedPreferences prefs,
    required String today,
  }) async {
    if (_resetInProgress || _disposed) {
      return;
    }

    _resetInProgress = true;

    try {
      _remainingCount = _initialCount;

      await prefs.setInt(
        _counterKey,
        _remainingCount,
      );

      if (_disposed) {
        return;
      }

      await prefs.setString(
        _dateKey,
        today,
      );

      if (!mounted || _disposed) {
        return;
      }

      setState(() {});

      HapticFeedback.selectionClick();
    } finally {
      _resetInProgress = false;
    }
  }

  // ============================================================
  // MIDNIGHT TIMER
  // ============================================================

  void _scheduleMidnightCheck() {
    if (_disposed) {
      return;
    }

    _midnightTimer?.cancel();

    final DateTime now = DateTime.now();

    final DateTime nextMidnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
      0,
      0,
      1,
    );

    final Duration untilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(
      untilMidnight,
      () async {
        if (_disposed) {
          return;
        }

        await _performMidnightReset();

        if (mounted && !_disposed) {
          _scheduleMidnightCheck();
        }
      },
    );
  }

  Future<void> _performMidnightReset() async {
    if (_disposed) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_disposed) {
      return;
    }

    final String today = _todayKey();

    final String? savedDate = prefs.getString(_dateKey);

    if (savedDate == today) {
      return;
    }

    await _resetForNewDay(
      prefs: prefs,
      today: today,
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveProgress() async {
    if (_disposed) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_disposed) {
      return;
    }

    await prefs.setInt(
      _counterKey,
      _remainingCount,
    );

    if (_disposed) {
      return;
    }

    await prefs.setString(
      _dateKey,
      _todayKey(),
    );
  }

  // ============================================================
  // COUNTER
  // ============================================================

  void _decrementCounter() {
    if (_remainingCount <= 0 || _disposed) {
      return;
    }

    setState(() {
      _remainingCount--;
    });

    _saveProgress();

    HapticFeedback.lightImpact();

    if (_remainingCount == 0 && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'أحسنت، اكتمل عدد التكرار لهذا الدعاء',
              style: TextStyle(
                fontFamily: 'Amiri',
              ),
            ),
            backgroundColor: Color(0xFF1B342B),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  void _resetCounter() {
    if (_disposed) {
      return;
    }

    setState(() {
      _remainingCount = _initialCount;
    });

    _saveProgress();

    HapticFeedback.mediumImpact();
  }

  // ============================================================
  // نسخ
  // ============================================================

  void _copyDua() {
    Clipboard.setData(
      ClipboardData(
        text: widget.content,
      ),
    );

    if (!mounted || _disposed) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'تم نسخ الدعاء بنجاح',
            style: TextStyle(
              fontFamily: 'Amiri',
            ),
          ),
          backgroundColor: Color(0xFF1B342B),
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // مشاركة
  // ============================================================

  Future<void> _shareDua() async {
    await Share.share(
      '${widget.title}\n\n'
      '${widget.content}\n\n'
      '(${widget.source})',
      subject: widget.title,
    );
  }

  // ============================================================
  // اسم التكرار
  // ============================================================

  String _repeatLabel(int count) {
    if (count == 1) {
      return 'مرة';
    }

    if (count == 2) {
      return 'مرتان';
    }

    if (count >= 3 && count <= 10) {
      return 'مرات';
    }

    return 'مرة';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = theme.scaffoldBackgroundColor;

    final Color appBarColor = isDark ? const Color(0xFF1B342B) : Colors.white;

    final Color cardColor = isDark ? const Color(0xFF132A22) : Colors.white;

    final Color secondaryCardColor =
        isDark ? const Color(0xFF1B342B) : const Color(0xFFEAF0EC);

    final Color titleColor =
        isDark ? const Color(0xFFF0E0B5) : const Color(0xFF1B342B);

    final Color goldColor =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF9A7412);

    final Color lightGoldColor =
        isDark ? const Color(0xFFC9B896) : const Color(0xFF8F7022);

    final Color secondaryColor =
        isDark ? const Color(0xFF9AB09F) : const Color(0xFF65756D);

    final bool isCompleted = _remainingCount == 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'Amiri',
            color: goldColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: goldColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_rounded,
              color: goldColor,
            ),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              color: goldColor,
            ),
            onPressed: _copyDua,
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: goldColor,
            ),
            onPressed: _shareDua,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Text(
                        'بسم الله',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(
                                  alpha: 0.03,
                                )
                              : const Color(
                                  0xFF1B342B,
                                ).withValues(
                                  alpha: 0.025,
                                ),
                          fontSize: 80,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryCardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: lightGoldColor.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: lightGoldColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: goldColor.withValues(
                            alpha: isDark ? 0.10 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: goldColor.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: goldColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الفضل:',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: goldColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.virtue,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: titleColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: lightGoldColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: lightGoldColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Icon(
                                Icons.repeat_rounded,
                                color: lightGoldColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'عدد التكرار المستحب:',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: secondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_initialCount ${_repeatLabel(_initialCount)}',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: titleColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Text(
                                '$_initialCount',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: goldColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: lightGoldColor.withValues(
                              alpha: 0.40,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: lightGoldColor,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star_rounded,
                                  color: lightGoldColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: lightGoldColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: titleColor,
                                fontSize: 22,
                                height: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: lightGoldColor,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star_rounded,
                                  color: lightGoldColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: lightGoldColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: secondaryCardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: lightGoldColor.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.book_rounded,
                              color: lightGoldColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'المصدر: ${widget.source}',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: secondaryColor,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: secondaryCardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted
                                ? goldColor
                                : lightGoldColor.withValues(
                                    alpha: 0.40,
                                  ),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isCompleted ? 'تم إكمال الدعاء' : 'العداد',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: isCompleted ? goldColor : lightGoldColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: goldColor.withValues(
                                  alpha: isDark ? 0.10 : 0.08,
                                ),
                                border: Border.all(
                                  color:
                                      isCompleted ? goldColor : lightGoldColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$_remainingCount',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    color: isCompleted ? goldColor : titleColor,
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isCompleted ? null : _decrementCounter,
                                icon: Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.touch_app_rounded,
                                ),
                                label: Text(
                                  isCompleted
                                      ? 'اكتمل التكرار'
                                      : 'اضغط للتسبيح',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldColor,
                                  foregroundColor: isDark
                                      ? const Color(
                                          0xFF2C1E08,
                                        )
                                      : Colors.white,
                                  disabledBackgroundColor: goldColor.withValues(
                                    alpha: 0.40,
                                  ),
                                  disabledForegroundColor: isDark
                                      ? const Color(
                                          0xFF2C1E08,
                                        ).withValues(
                                          alpha: 0.60,
                                        )
                                      : Colors.white.withValues(
                                          alpha: 0.65,
                                        ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _resetCounter,
                                icon: const Icon(
                                  Icons.restart_alt_rounded,
                                ),
                                label: const Text(
                                  'إعادة العداد',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: lightGoldColor,
                                  side: BorderSide(
                                    color: lightGoldColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _copyDua,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEAD79F),
                                Color(0xFFC9A86A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                color: Color(0xFF2C1E08),
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'نسخ الدعاء',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: Color(0xFF2C1E08),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
