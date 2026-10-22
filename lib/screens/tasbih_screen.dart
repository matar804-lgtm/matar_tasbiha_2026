import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreenNew extends StatefulWidget {
  const TasbihScreenNew({
    super.key,
  });

  @override
  State<TasbihScreenNew> createState() =>
      _TasbihScreenNewState();
}

class _TasbihScreenNewState
    extends State<TasbihScreenNew> {
  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  int _currentDhikrIndex = 0;

  final List<Map<String, dynamic>> _adhkar = [
    {
      'text': 'سُبْحَانَ اللَّهِ',
      'target': 33,
    },
    {
      'text': 'الْحَمْدُ لِلَّهِ',
      'target': 33,
    },
    {
      'text': 'اللَّهُ أَكْبَرُ',
      'target': 34,
    },
    {
      'text': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'target': 100,
    },
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'target': 100,
    },
    {
      'text': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
      'target': 100,
    },
    {
      'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'target': 100,
    },
    {
      'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'target': 100,
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadState();
  }

  // ============================================================
  // تحميل الحالة
  // ============================================================

  Future<void> _loadState() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final int savedIndex =
          prefs.getInt(
            'current_dhikr_index',
          ) ??
          0;

      final int safeIndex =
          savedIndex >= 0 &&
                  savedIndex < _adhkar.length
              ? savedIndex
              : 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _count =
            prefs.getInt(
              'tasbih_count',
            ) ??
            0;

        _target =
            prefs.getInt(
              'tasbih_target',
            ) ??
            (_adhkar[safeIndex]['target']
                as int);

        _totalCount =
            prefs.getInt(
              'tasbih_total_count',
            ) ??
            0;

        _currentDhikrIndex =
            safeIndex;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Tasbih state loading failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // حفظ الحالة
  // ============================================================

  Future<void> _saveState() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setInt(
        'tasbih_count',
        _count,
      );

      await prefs.setInt(
        'tasbih_target',
        _target,
      );

      await prefs.setInt(
        'tasbih_total_count',
        _totalCount,
      );

      await prefs.setInt(
        'current_dhikr_index',
        _currentDhikrIndex,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Tasbih state saving failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // زيادة العداد
  // ============================================================

  void _incrementCount() {
    setState(() {
      _count++;
      _totalCount++;

      if (_count >= _target) {
        _currentDhikrIndex =
            (_currentDhikrIndex + 1) %
                _adhkar.length;

        _target =
            _adhkar[_currentDhikrIndex]
                ['target'] as int;

        _count = 0;
      }
    });

    _saveState();

    HapticFeedback.lightImpact();
  }

  // ============================================================
  // تصفير العداد الحالي
  // ============================================================

  void _resetCount() {
    setState(() {
      _count = 0;
    });

    _saveState();

    HapticFeedback.mediumImpact();
  }

  // ============================================================
  // تصفير الكل
  // ============================================================

  void _resetAll() {
    setState(() {
      _count = 0;
      _totalCount = 0;
    });

    _saveState();

    HapticFeedback.mediumImpact();
  }

  // ============================================================
  // الأرقام العربية
  // ============================================================

  String _toArabicNumber(
    int number,
  ) {
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
          (c) =>
              arabicNumbers[int.parse(c)],
        )
        .join();
  }

  // ============================================================
  // معلومات اللون
  // ============================================================

  _TasbihColors _getColors(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    final bool isDark =
        theme.brightness ==
            Brightness.dark;

    return _TasbihColors(
      isDark: isDark,
      background: theme
          .scaffoldBackgroundColor,
      header: isDark
          ? const Color(0xFF1B342B)
          : Colors.white,
      card: isDark
          ? const Color(0xFF132A22)
          : Colors.white,
      secondaryCard: isDark
          ? const Color(0xFF1B342B)
          : const Color(0xFFEAF0EC),
      primaryText: isDark
          ? Colors.white
          : const Color(0xFF1B342B),
      secondaryText: isDark
          ? Colors.white70
          : const Color(0xFF65756D),
      gold: isDark
          ? const Color(0xFFD4AF37)
          : const Color(0xFF9A7412),
      lightGold: isDark
          ? const Color(0xFFC9B896)
          : const Color(0xFF8F7022),
    );
  }

  // ============================================================
  // الواجهة
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final _TasbihColors colors =
        _getColors(context);

    return GestureDetector(
      behavior:
          HitTestBehavior.translucent,
      onTap: _incrementCount,
      child: Scaffold(
        backgroundColor:
            colors.background,
        body: Container(
          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topCenter,
              end:
                  Alignment.bottomCenter,
              colors: colors.isDark
                  ? const [
                      Color(0xFF0A0E27),
                      Color(0xFF1A1F3A),
                      Color(0xFF0D1B2A),
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
                // ==================================================
                // الشريط العلوي
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons
                              .arrow_back_ios,
                          color:
                              colors.lightGold,
                        ),
                        onPressed:
                            () => Navigator
                                .pop(
                          context,
                        ),
                      ),
                      Text(
                        'التسبيح',
                        style:
                            TextStyle(
                          fontFamily:
                              'Amiri',
                          fontSize:
                              24,
                          color:
                              colors.primaryText,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color:
                              colors.gold,
                        ),
                        onPressed:
                            _showSettings,
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // الذكر الحالي
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colors.gold
                              .withValues(
                        alpha:
                            colors.isDark
                                ? 0.10
                                : 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      border:
                          Border.all(
                        color:
                            colors.gold
                                .withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الذكر الحالي',
                          style:
                              TextStyle(
                            fontFamily:
                                'Amiri',
                            color:
                                colors.secondaryText,
                            fontSize:
                                13,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          _adhkar[
                              _currentDhikrIndex]
                              ['text'] as String,
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            fontFamily:
                                'Amiri',
                            fontSize:
                                24,
                            color:
                                colors.primaryText,
                            fontWeight:
                                FontWeight.bold,
                            height:
                                1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 35,
                ),

                // ==================================================
                // دائرة العداد
                // ==================================================

                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  width: 280,
                  height: 280,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    gradient:
                        LinearGradient(
                      colors:
                          colors.isDark
                              ? const [
                                  Color(
                                    0xFFD4AF37,
                                  ),
                                  Color(
                                    0xFFB8860B,
                                  ),
                                ]
                              : const [
                                  Color(
                                    0xFFE4C866,
                                  ),
                                  Color(
                                    0xFFB69228,
                                  ),
                                ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            colors.gold
                                .withValues(
                          alpha:
                              colors.isDark
                                  ? 0.55
                                  : 0.30,
                        ),
                        blurRadius:
                            30,
                        spreadRadius:
                            8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        _toArabicNumber(
                          _count,
                        ),
                        style:
                            TextStyle(
                          fontFamily:
                              'Amiri',
                          fontSize:
                              90,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'من ${_toArabicNumber(_target)}',
                        style:
                            const TextStyle(
                          fontSize: 20,
                          color:
                              Colors.white70,
                          fontFamily:
                              'Amiri',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  'اضغط في أي مكان للعد',
                  style: TextStyle(
                    fontFamily:
                        'Amiri',
                    color:
                        colors.secondaryText,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                // ==================================================
                // الأزرار السفلية
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Wrap(
                    alignment:
                        WrapAlignment
                            .center,
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      PopupMenuButton<
                          String>(
                        color:
                            colors.card,
                        onSelected:
                            (value) {
                          if (value ==
                              'reset') {
                            _resetCount();
                          }

                          if (value ==
                              'resetAll') {
                            _resetAll();
                          }
                        },
                        itemBuilder:
                            (context) {
                          return [
                            PopupMenuItem<
                                String>(
                              value:
                                  'reset',
                              child: Text(
                                'تصفير العداد',
                                style:
                                    TextStyle(
                                  fontFamily:
                                      'Amiri',
                                  color:
                                      colors.primaryText,
                                ),
                              ),
                            ),
                            PopupMenuItem<
                                String>(
                              value:
                                  'resetAll',
                              child: Text(
                                'تصفير الكل',
                                style:
                                    TextStyle(
                                  fontFamily:
                                      'Amiri',
                                  color:
                                      colors.primaryText,
                                ),
                              ),
                            ),
                          ];
                        },
                        child:
                            Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                20,
                            vertical:
                                12,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                colors.primaryText
                                    .withValues(
                              alpha:
                                  0.10,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              25,
                            ),
                            border:
                                Border.all(
                              color:
                                  colors.lightGold
                                      .withValues(
                                alpha:
                                    0.35,
                              ),
                            ),
                          ),
                          child:
                              Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,
                            children: [
                              Icon(
                                Icons
                                    .refresh,
                                color:
                                    colors.primaryText,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                'تصفير',
                                style:
                                    TextStyle(
                                  fontFamily:
                                      'Amiri',
                                  fontSize:
                                      16,
                                  color:
                                      colors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              colors.primaryText
                                  .withValues(
                            alpha:
                                0.10,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            25,
                          ),
                          border:
                              Border.all(
                            color:
                                colors.lightGold
                                    .withValues(
                              alpha:
                                  0.35,
                            ),
                          ),
                        ),
                        child:
                            Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .analytics,
                              color:
                                  colors.gold,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'الإجمالي: '
                              '${_toArabicNumber(_totalCount)}',
                              style:
                                  TextStyle(
                                fontFamily:
                                    'Amiri',
                                fontSize:
                                    16,
                                color:
                                    colors.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // ============================================================
  // إعدادات التسبيح
  // ============================================================

  void _showSettings() {
    final _TasbihColors colors =
        _getColors(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          colors.card,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        colors.secondaryText
                            .withValues(
                      alpha: 0.35,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      3,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  'إعدادات التسبيح',
                  style:
                      TextStyle(
                    fontFamily:
                        'Amiri',
                    fontSize: 22,
                    color:
                        colors.gold,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ListTile(
                  leading:
                      Icon(
                    Icons
                        .format_list_numbered,
                    color:
                        colors.gold,
                  ),
                  title:
                      Text(
                    'مجموعات التسبيح',
                    style:
                        TextStyle(
                      color:
                          colors.primaryText,
                      fontFamily:
                          'Amiri',
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _showDhikrSelector();
                  },
                ),

                Divider(
                  color:
                      colors.gold
                          .withValues(
                    alpha: 0.25,
                  ),
                ),

                ListTile(
                  leading:
                      Icon(
                    Icons.flag,
                    color:
                        colors.gold,
                  ),
                  title:
                      Text(
                    'تغيير الهدف',
                    style:
                        TextStyle(
                      color:
                          colors.primaryText,
                      fontFamily:
                          'Amiri',
                    ),
                  ),
                  subtitle:
                      Text(
                    'الهدف الحالي: $_target',
                    style:
                        TextStyle(
                      color:
                          colors.secondaryText,
                      fontFamily:
                          'Amiri',
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _showTargetSelector();
                  },
                ),

                Divider(
                  color:
                      colors.gold
                          .withValues(
                    alpha: 0.25,
                  ),
                ),

                ListTile(
                  leading:
                      Icon(
                    Icons.refresh,
                    color:
                        colors.gold,
                  ),
                  title:
                      Text(
                    'تصفير العداد',
                    style:
                        TextStyle(
                      color:
                          colors.primaryText,
                      fontFamily:
                          'Amiri',
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _resetCount();
                  },
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // اختيار الذكر
  // ============================================================

  void _showDhikrSelector() {
    final _TasbihColors colors =
        _getColors(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          colors.card,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        colors.secondaryText
                            .withValues(
                      alpha: 0.35,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      3,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  'اختر الذكر',
                  style:
                      TextStyle(
                    fontFamily:
                        'Amiri',
                    fontSize: 22,
                    color:
                        colors.gold,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  height: 300,
                  child:
                      ListView.builder(
                    itemCount:
                        _adhkar.length,
                    itemBuilder:
                        (context, index) {
                      final bool isSelected =
                          index ==
                              _currentDhikrIndex;

                      return ListTile(
                        leading:
                            Icon(
                          isSelected
                              ? Icons
                                  .check_circle
                              : Icons
                                  .circle_outlined,
                          color:
                              isSelected
                                  ? colors.gold
                                  : colors.secondaryText,
                        ),
                        title:
                            Text(
                          _adhkar[index]
                              ['text'] as String,
                          style:
                              TextStyle(
                            fontFamily:
                                'Amiri',
                            fontSize:
                                16,
                            color:
                                isSelected
                                    ? colors.gold
                                    : colors.primaryText,
                          ),
                        ),
                        subtitle:
                            Text(
                          'الهدف: ${_adhkar[index]['target']}',
                          style:
                              TextStyle(
                            fontFamily:
                                'Amiri',
                            fontSize:
                                11,
                            color:
                                colors.secondaryText,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _currentDhikrIndex =
                                index;

                            _target =
                                _adhkar[index]
                                    ['target'] as int;

                            _count = 0;
                          });

                          _saveState();

                          Navigator.pop(
                            sheetContext,
                          );
                        },
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

  // ============================================================
  // اختيار الهدف
  // ============================================================

  void _showTargetSelector() {
    final _TasbihColors colors =
        _getColors(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              colors.card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            side:
                BorderSide(
              color:
                  colors.gold,
              width: 2,
            ),
          ),
          title:
              Text(
            'اختر الهدف',
            style:
                TextStyle(
              fontFamily:
                  'Amiri',
              color:
                  colors.gold,
            ),
          ),
          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children:
                [33, 99, 100, 500, 1000]
                    .map(
              (target) {
                return ListTile(
                  title:
                      Text(
                    '$target مرة',
                    style:
                        TextStyle(
                      fontFamily:
                          'Amiri',
                      color:
                          colors.primaryText,
                    ),
                  ),
                  trailing:
                      target ==
                              _target
                          ? Icon(
                              Icons.check,
                              color:
                                  colors.gold,
                            )
                          : null,
                  onTap: () {
                    setState(() {
                      _target =
                          target;

                      _count = 0;
                    });

                    _saveState();

                    Navigator.pop(
                      dialogContext,
                    );
                  },
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

// ============================================================================
// ألوان شاشة التسبيح
// ============================================================================

class _TasbihColors {
  final bool isDark;

  final Color background;
  final Color header;
  final Color card;
  final Color secondaryCard;

  final Color primaryText;
  final Color secondaryText;

  final Color gold;
  final Color lightGold;

  const _TasbihColors({
    required this.isDark,
    required this.background,
    required this.header,
    required this.card,
    required this.secondaryCard,
    required this.primaryText,
    required this.secondaryText,
    required this.gold,
    required this.lightGold,
  });
}