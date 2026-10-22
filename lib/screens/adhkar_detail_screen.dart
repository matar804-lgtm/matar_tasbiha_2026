import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> duas;
  final int categoryIndex;
  final Color color;

  const AdhkarDetailScreen({
    super.key,
    required this.title,
    required this.duas,
    required this.categoryIndex,
    required this.color,
  });

  @override
  State<AdhkarDetailScreen> createState() =>
      _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen>
    with WidgetsBindingObserver {
  late List<int> _counters;

  Timer? _midnightTimer;

  bool _loading = true;
  bool _resetInProgress = false;

  String get _counterKey =>
      'adhkar_counters_${widget.categoryIndex}';

  String get _dateKey =>
      'adhkar_counters_date_${widget.categoryIndex}';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _counters = List<int>.filled(
      widget.duas.length,
      0,
    );

    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();

    super.dispose();
  }

  // ===========================================================================
  // APP LIFECYCLE
  // ===========================================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _checkForNewDay();
      _scheduleMidnightCheck();
    }
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  Future<void> _initialize() async {
    await _checkForNewDay();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    _scheduleMidnightCheck();
  }

  // ===========================================================================
  // DATE
  // ===========================================================================

  String _todayKey() {
    final DateTime now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // DAILY RESET CHECK
  // ===========================================================================

  Future<void> _checkForNewDay() async {
    if (_resetInProgress) {
      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final String today = _todayKey();
    final String? savedDate =
        prefs.getString(_dateKey);

    // أول مرة تُفتح فيها هذه الفئة.
    if (savedDate == null) {
      await _loadCounters(prefs);

      await prefs.setString(
        _dateKey,
        today,
      );

      return;
    }

    // نفس اليوم → تحميل العدادات المعتادة.
    if (savedDate == today) {
      await _loadCounters(prefs);
      return;
    }

    // تاريخ جديد → تصفير جميع عدادات هذه الفئة.
    await _resetAllCountersForNewDay(
      prefs: prefs,
      today: today,
    );
  }

  // ===========================================================================
  // LOAD
  // ===========================================================================

  Future<void> _loadCounters(
    SharedPreferences prefs,
  ) async {
    final List<String>? savedStrings =
        prefs.getStringList(_counterKey);

    if (savedStrings == null ||
        savedStrings.length != _counters.length) {
      return;
    }

    for (int i = 0; i < savedStrings.length; i++) {
      _counters[i] =
          int.tryParse(savedStrings[i]) ?? 0;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ===========================================================================
  // NEW DAY RESET
  // ===========================================================================

  Future<void> _resetAllCountersForNewDay({
    required SharedPreferences prefs,
    required String today,
  }) async {
    _resetInProgress = true;

    try {
      for (int i = 0; i < _counters.length; i++) {
        _counters[i] = 0;
      }

      await prefs.setStringList(
        _counterKey,
        _counters
            .map(
              (int value) => value.toString(),
            )
            .toList(),
      );

      await prefs.setString(
        _dateKey,
        today,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      HapticFeedback.selectionClick();
    } finally {
      _resetInProgress = false;
    }
  }

  // ===========================================================================
  // MIDNIGHT TIMER
  // ===========================================================================

  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();

    final DateTime now =
        DateTime.now();

    final DateTime nextMidnight =
        DateTime(
      now.year,
      now.month,
      now.day + 1,
      0,
      0,
      1,
    );

    final Duration untilMidnight =
        nextMidnight.difference(now);

    _midnightTimer = Timer(
      untilMidnight,
      () async {
        await _performMidnightReset();

        if (mounted) {
          _scheduleMidnightCheck();
        }
      },
    );
  }

  Future<void> _performMidnightReset() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final String today = _todayKey();

    final String? savedDate =
        prefs.getString(_dateKey);

    // حماية إضافية من إعادة التصفير أكثر من مرة.
    if (savedDate == today) {
      return;
    }

    await _resetAllCountersForNewDay(
      prefs: prefs,
      today: today,
    );
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveProgress() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      _counterKey,
      _counters
          .map(
            (int value) => value.toString(),
          )
          .toList(),
    );

    await prefs.setString(
      _dateKey,
      _todayKey(),
    );
  }

  // ===========================================================================
  // COUNTERS
  // ===========================================================================

  void _increment(
    int index,
    int target,
  ) {
    if (index < 0 ||
        index >= _counters.length) {
      return;
    }

    if (_counters[index] >= target) {
      return;
    }

    setState(() {
      _counters[index]++;
    });

    _saveProgress();

    HapticFeedback.lightImpact();
  }

  void _reset(
    int index,
  ) {
    if (index < 0 ||
        index >= _counters.length) {
      return;
    }

    setState(() {
      _counters[index] = 0;
    });

    _saveProgress();

    HapticFeedback.mediumImpact();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F2027),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1B5E20),

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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFFD4AF37),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.home_rounded,
              color: Color(0xFFD4AF37),
            ),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  widget.duas.length,
              itemBuilder:
                  (context, index) {
                return _buildDuaCard(
                  index,
                  widget.duas[index],
                );
              },
            ),
    );
  }

  // ===========================================================================
  // DUA CARD
  // ===========================================================================

  Widget _buildDuaCard(
    int index,
    Map<String, dynamic> dua,
  ) {
    final int currentCount =
        _counters[index];

    final int targetCount =
        (dua['count'] as num?)?.toInt() ?? 1;

    final bool isCompleted =
        currentCount >= targetCount;

    final String content =
        dua['content']?.toString() ?? '';

    final String reference =
        dua['reference']?.toString() ?? '';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF1B5E20)
                .withValues(
          alpha: 0.6,
        ),

        borderRadius:
            BorderRadius.circular(
          15,
        ),

        border:
            Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50)
              : widget.color.withValues(
                  alpha: 0.5,
                ),
          width: 2,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            content,
            style:
                const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              color: Color(0xFFD4AF37),
              height: 1.8,
              fontWeight:
                  FontWeight.w600,
            ),
            textAlign:
                TextAlign.right,
          ),

          if (reference.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            Container(
              padding:
                  const EdgeInsets.all(
                10,
              ),

              decoration:
                  BoxDecoration(
                color:
                    widget.color.withValues(
                  alpha: 0.2,
                ),

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),

                border:
                    Border.all(
                  color:
                      widget.color.withValues(
                    alpha: 0.4,
                  ),
                  width: 1,
                ),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.color,
                    size: 18,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Text(
                      reference,
                      style:
                          TextStyle(
                        fontFamily:
                            'Amiri',
                        fontSize: 13,
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.9,
                        ),
                        fontStyle:
                            FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),

                decoration:
                    BoxDecoration(
                  color: isCompleted
                      ? const Color(
                          0xFF4CAF50,
                        )
                      : widget.color,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: Text(
                  '$currentCount / $targetCount',
                  style:
                      const TextStyle(
                    fontFamily:
                        'Amiri',
                    fontSize: 16,
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Row(
                children: [
                  if (!isCompleted)
                    GestureDetector(
                      onTap: () {
                        _increment(
                          index,
                          targetCount,
                        );
                      },

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            colors: [
                              widget.color,
                              widget.color
                                  .withValues(
                                alpha: 0.7,
                              ),
                            ],
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),

                        child:
                            const Text(
                          'اضغط',
                          style:
                              TextStyle(
                            fontFamily:
                                'Amiri',
                            fontSize: 15,
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                    width: 8,
                  ),

                  GestureDetector(
                    onTap: () {
                      _reset(index);
                    },

                    child: Container(
                      padding:
                          const EdgeInsets
                              .all(
                        8,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.2,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),

                      child: const Icon(
                        Icons.refresh,
                        color:
                            Colors.white,
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
  }
}