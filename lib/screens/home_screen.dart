import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ===========================================================================
  // COUNTERS
  // ===========================================================================

  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  int _dailyCount = 0;

  String _currentDhikr = 'سُبْحَانَ اللَّهِ';

  int _currentDhikrIndex = 0;

  // ===========================================================================
  // UI STATE
  // ===========================================================================

  bool _showCompletionMessage = false;

  Timer? _completionTimer;
  Timer? _midnightTimer;

  bool _isDailyResetRunning = false;
  bool _isLoading = true;

  // ===========================================================================
  // ANIMATIONS
  // ===========================================================================

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _arcController;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  bool _showStars = false;

  // ===========================================================================
  // SETTINGS
  // ===========================================================================

  bool _showArabicNumbers = true;
  bool _showPercentage = true;
  bool _showNextDhikr = true;
  bool _showRippleEffect = true;
  bool _showStarsEffect = true;
  bool _showHaptic = true;

  // ===========================================================================
  // STABLE STAR POSITIONS
  // ===========================================================================

  late final List<_StarParticle> _stars;

  // ===========================================================================
  // ADHKAR
  // ===========================================================================

  final List<String> _adhkar = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
  ];

  // ===========================================================================
  // STORAGE KEY
  // ===========================================================================

  static const String _dailyDateKey = 'tasbih_daily_date';

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );

    _stars = _generateStars();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 150,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    _initialize();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        AppHelpers.requestReviewIfNeeded(
          context,
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _pulseController.dispose();
    _arcController.dispose();
    _rippleController.dispose();

    _completionTimer?.cancel();
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
    await Future.wait([
      _loadSettings(),
      _loadCount(),
    ]);

    await _checkForNewDay();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    _scheduleMidnightCheck();
  }

  // ===========================================================================
  // SETTINGS
  // ===========================================================================

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      _showArabicNumbers = prefs.getBool(
            'show_arabic_numbers',
          ) ??
          true;

      _showPercentage = prefs.getBool(
            'show_percentage',
          ) ??
          true;

      _showNextDhikr = prefs.getBool(
            'show_next_dhikr',
          ) ??
          true;

      _showRippleEffect = prefs.getBool(
            'show_ripple',
          ) ??
          true;

      _showStarsEffect = prefs.getBool(
            'show_stars',
          ) ??
          true;

      _showHaptic = prefs.getBool(
            'show_haptic',
          ) ??
          true;
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'show_arabic_numbers',
      _showArabicNumbers,
    );

    await prefs.setBool(
      'show_percentage',
      _showPercentage,
    );

    await prefs.setBool(
      'show_next_dhikr',
      _showNextDhikr,
    );

    await prefs.setBool(
      'show_ripple',
      _showRippleEffect,
    );

    await prefs.setBool(
      'show_stars',
      _showStarsEffect,
    );

    await prefs.setBool(
      'show_haptic',
      _showHaptic,
    );
  }

  // ===========================================================================
  // COUNTER LOAD
  // ===========================================================================

  Future<void> _loadCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int savedIndex = prefs.getInt(
          'current_dhikr_index',
        ) ??
        0;

    final int safeIndex =
        savedIndex >= 0 && savedIndex < _adhkar.length ? savedIndex : 0;

    if (!mounted) {
      return;
    }

    setState(() {
      _count = prefs.getInt(
            'tasbih_count',
          ) ??
          0;

      _target = prefs.getInt(
            'tasbih_target',
          ) ??
          33;

      _totalCount = prefs.getInt(
            'tasbih_total',
          ) ??
          0;

      _dailyCount = prefs.getInt(
            'tasbih_daily',
          ) ??
          0;

      _currentDhikr = prefs.getString(
            'tasbih_dhikr',
          ) ??
          _adhkar[safeIndex];

      _currentDhikrIndex = safeIndex;
    });
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
  // DAILY RESET
  // ===========================================================================

  Future<void> _checkForNewDay() async {
    if (_isDailyResetRunning) {
      return;
    }

    _isDailyResetRunning = true;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String today = _todayKey();

      final String? savedDate = prefs.getString(
        _dailyDateKey,
      );

      // أول تشغيل بعد إضافة نظام اليوم.
      if (savedDate == null) {
        await prefs.setString(
          _dailyDateKey,
          today,
        );

        return;
      }

      // نفس اليوم.
      if (savedDate == today) {
        return;
      }

      // يوم جديد.
      _dailyCount = 0;

      await prefs.setInt(
        'tasbih_daily',
        0,
      );

      await prefs.setString(
        _dailyDateKey,
        today,
      );

      if (mounted) {
        setState(() {
          _dailyCount = 0;
        });
      }
    } finally {
      _isDailyResetRunning = false;
    }
  }

  // ===========================================================================
  // MIDNIGHT TIMER
  // ===========================================================================

  void _scheduleMidnightCheck() {
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

    final Duration duration = nextMidnight.difference(
      now,
    );

    _midnightTimer = Timer(
      duration,
      () async {
        await _performMidnightReset();

        if (mounted) {
          _scheduleMidnightCheck();
        }
      },
    );
  }

  Future<void> _performMidnightReset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String today = _todayKey();

    final String? savedDate = prefs.getString(
      _dailyDateKey,
    );

    if (savedDate == today) {
      return;
    }

    _dailyCount = 0;

    await prefs.setInt(
      'tasbih_daily',
      0,
    );

    await prefs.setString(
      _dailyDateKey,
      today,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _dailyCount = 0;
    });

    HapticFeedback.selectionClick();
  }

  // ===========================================================================
  // SAVE COUNTER
  // ===========================================================================

  Future<void> _saveCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'tasbih_count',
      _count,
    );

    await prefs.setInt(
      'tasbih_target',
      _target,
    );

    await prefs.setInt(
      'tasbih_total',
      _totalCount,
    );

    await prefs.setInt(
      'tasbih_daily',
      _dailyCount,
    );

    await prefs.setString(
      'tasbih_dhikr',
      _currentDhikr,
    );

    await prefs.setInt(
      'current_dhikr_index',
      _currentDhikrIndex,
    );

    await prefs.setString(
      _dailyDateKey,
      _todayKey(),
    );
  }

  // ===========================================================================
  // INCREMENT
  // ===========================================================================

  void _incrementCount() {
    setState(() {
      _count++;
      _totalCount++;
      _dailyCount++;

      if (_count >= _target) {
        _currentDhikrIndex = (_currentDhikrIndex + 1) % _adhkar.length;

        _currentDhikr = _adhkar[_currentDhikrIndex];

        _showCompletionMessage = true;

        _completionTimer?.cancel();

        _completionTimer = Timer(
          const Duration(
            seconds: 1,
          ),
          () {
            if (!mounted) {
              return;
            }

            setState(() {
              _showCompletionMessage = false;
            });
          },
        );

        _count = 0;
      }
    });

    _saveCount();

    _pulseController.forward().then(
      (_) {
        if (mounted) {
          _pulseController.reverse();
        }
      },
    );

    _arcController.forward().then(
      (_) {
        if (mounted) {
          _arcController.reverse();
        }
      },
    );

    if (_showRippleEffect) {
      _rippleController.forward().then(
        (_) {
          if (mounted) {
            _rippleController.reset();
          }
        },
      );
    }

    if (_showStarsEffect) {
      setState(() {
        _showStars = true;
      });

      Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
        () {
          if (mounted) {
            setState(() {
              _showStars = false;
            });
          }
        },
      );
    }

    if (_showHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  void _resetCount() {
    setState(() {
      _count = 0;
      _dailyCount = 0;
      _showCompletionMessage = false;
    });

    _saveCount();

    if (_showHaptic) {
      HapticFeedback.mediumImpact();
    }
  }

  void _resetAll() {
    setState(() {
      _count = 0;
      _totalCount = 0;
      _dailyCount = 0;
      _showCompletionMessage = false;
    });

    _saveCount();

    if (_showHaptic) {
      HapticFeedback.mediumImpact();
    }
  }

  // ===========================================================================
  // RESET DIALOG
  // ===========================================================================

  void _showResetDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B5E20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(
                    2,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'خيارات التصفير',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFD4AF37,
                    ).withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'تصفير العداد فقط',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'إعادة العداد إلى 0 مع الاحتفاظ بالإجمالي ($_totalCount)',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: Colors.white.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                  _resetCount();
                },
              ),
              const Divider(
                color: Color(0xFFD4AF37),
                thickness: 1,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE8837C,
                    ).withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Color(0xFFE8837C),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'تصفير الكل',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                subtitle: const Text(
                  'إعادة العداد والإجمالي إلى 0',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                  _resetAll();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TARGET
  // ===========================================================================

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          title: const Text(
            'اختر الهدف',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Color(0xFFD4AF37),
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              33,
              99,
              100,
              500,
              1000,
            ].map(
              (target) {
                return ListTile(
                  title: Text(
                    '$target مرة',
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  trailing: target == _target
                      ? const Icon(
                          Icons.check,
                          color: Color(
                            0xFFD4AF37,
                          ),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _target = target;
                      _showCompletionMessage = false;
                    });

                    _saveCount();

                    Navigator.pop(
                      context,
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

  // ===========================================================================
  // DHIKR SELECTION
  // ===========================================================================

  void _showDhikrDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          title: const Text(
            'اختر الذكر',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Color(0xFFD4AF37),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _adhkar.map(
                (dhikr) {
                  return ListTile(
                    title: Text(
                      dhikr,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: dhikr == _currentDhikr
                            ? const Color(
                                0xFFD4AF37,
                              )
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: dhikr == _currentDhikr
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(
                              0xFFD4AF37,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _currentDhikr = dhikr;
                        _count = 0;
                        _showCompletionMessage = false;

                        _currentDhikrIndex = _adhkar.indexOf(
                          dhikr,
                        );
                      });

                      _saveCount();

                      Navigator.pop(
                        context,
                      );
                    },
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // STATS
  // ===========================================================================

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          title: const Text(
            'الإحصائيات',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Color(0xFFD4AF37),
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                'الإجمالي',
                _totalCount,
              ),
              _buildStatItem(
                'اليوم',
                _dailyCount,
              ),
              _buildStatItem(
                'الهدف الحالي',
                _target,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String title,
    int value,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Amiri',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        _showArabicNumbers
            ? _toArabicNumbers(
                value,
              )
            : value.toString(),
        style: const TextStyle(
          fontFamily: 'Amiri',
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===========================================================================
  // SETTINGS DIALOG
  // ===========================================================================

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(
                0xFF1B5E20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              title: const Text(
                'الإعدادات',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Color(0xFFD4AF37),
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSwitchTile(
                      'الأرقام العربية',
                      _showArabicNumbers,
                      (value) {
                        setDialogState(
                          () => _showArabicNumbers = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      'نسبة الإنجاز',
                      _showPercentage,
                      (value) {
                        setDialogState(
                          () => _showPercentage = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      'إظهار الذكر التالي',
                      _showNextDhikr,
                      (value) {
                        setDialogState(
                          () => _showNextDhikr = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      'تأثير الموجات',
                      _showRippleEffect,
                      (value) {
                        setDialogState(
                          () => _showRippleEffect = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      'تأثير النجوم',
                      _showStarsEffect,
                      (value) {
                        setDialogState(
                          () => _showStarsEffect = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      'الاهتزاز',
                      _showHaptic,
                      (value) {
                        setDialogState(
                          () => _showHaptic = value,
                        );
                        setState(() {});
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Amiri',
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      value: value,
      activeThumbColor: const Color(0xFFD4AF37),
      onChanged: onChanged,
    );
  }

  // ===========================================================================
  // NUMBERS
  // ===========================================================================

  String _toArabicNumbers(
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
          (character) => arabicNumbers[int.parse(
            character,
          )],
        )
        .join();
  }

  // ===========================================================================
  // STARS
  // ===========================================================================

  List<_StarParticle> _generateStars() {
    final math.Random random = math.Random(20260825);

    return List<_StarParticle>.generate(
      8,
      (_) {
        return _StarParticle(
          left: 50 +
              random
                  .nextInt(
                    300,
                  )
                  .toDouble(),
          top: 100 +
              random
                  .nextInt(
                    300,
                  )
                  .toDouble(),
          size: 15 +
              random
                  .nextInt(
                    20,
                  )
                  .toDouble(),
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F2027),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37),
          ),
        ),
      );
    }

    final double progress =
        _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;

    final bool isCompleted = _count >= _target;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _incrementCount,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/bg_tasbih.jpg',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(
                  0,
                  0,
                  0,
                  0.3,
                ),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // RIPPLE
              // ---------------------------------------------------------------

              if (_showRippleEffect)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, child) {
                      return Center(
                        child: Container(
                          width: 300 * _rippleAnimation.value,
                          height: 300 * _rippleAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: 0.3 * (1 - _rippleAnimation.value),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // ---------------------------------------------------------------
              // STARS
              // ---------------------------------------------------------------

              if (_showStars)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: _stars.map(
                        (
                          _StarParticle star,
                        ) {
                          return Positioned(
                            left: star.left,
                            top: star.top,
                            child: Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: star.size,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),

              // ---------------------------------------------------------------
              // COMPLETION MESSAGE
              // ---------------------------------------------------------------

              if (_showCompletionMessage)
                Positioned.fill(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        padding: const EdgeInsets.all(
                          30,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1B5E20,
                          ),
                          borderRadius: BorderRadius.circular(
                            25,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFD4AF37,
                            ),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 25,
                              offset: const Offset(
                                0,
                                15,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                15,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Color(
                                  0xFFD4AF37,
                                ),
                                size: 70,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'ما شاء الله!',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFFD4AF37,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'تم إكمال $_target تسبيحة',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ---------------------------------------------------------------
              // MAIN UI
              // ---------------------------------------------------------------

              SafeArea(
                child: Column(
                  children: [
                    // ---------------------------------------------------------
                    // APP BAR
                    // ---------------------------------------------------------

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAppBarButton(
                            icon: Icons.favorite,
                            color: const Color(
                              0xFFE91E63,
                            ),
                            onTap: _showDhikrDialog,
                          ),
                          _buildAppBarButton(
                            icon: Icons.settings,
                            color: const Color(
                              0xFF1B5E20,
                            ),
                            onTap: _showSettingsDialog,
                          ),
                          const Expanded(
                            child: Text(
                              'تسبيحه',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                color: Color(
                                  0xFF1B5E20,
                                ),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildAppBarButton(
                            icon: Icons.home,
                            color: const Color(
                              0xFF1B5E20,
                            ),
                            onTap: () {
                              if (!mounted) {
                                return;
                              }

                              Navigator.of(
                                context,
                              ).popUntil(
                                (route) => route.isFirst,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ---------------------------------------------------------
                    // CURRENT DHIKR
                    // ---------------------------------------------------------

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF5A6B7C,
                        ),
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 10,
                            offset: const Offset(
                              0,
                              4,
                            ),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentDhikr,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ---------------------------------------------------------
                    // MAIN COUNTER
                    // ---------------------------------------------------------

                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: Listenable.merge(
                            [
                              _pulseAnimation,
                              _arcController,
                            ],
                          ),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: SizedBox(
                                width: 280,
                                height: 280,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomPaint(
                                      size: const Size(
                                        280,
                                        280,
                                      ),
                                      painter: ArcProgressPainter(
                                        progress: progress,
                                        arcAnimation: _arcController.value,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _showArabicNumbers
                                              ? _toArabicNumbers(
                                                  _count,
                                                )
                                              : _count.toString(),
                                          style: TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 90,
                                            fontWeight: FontWeight.bold,
                                            color: isCompleted
                                                ? const Color(
                                                    0xFF4CAF50,
                                                  )
                                                : Colors.white,
                                            shadows: const [
                                              Shadow(
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.4,
                                                ),
                                                blurRadius: 10,
                                                offset: Offset(
                                                  0,
                                                  4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        if (_showPercentage)
                                          Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 20,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              shadows: const [
                                                Shadow(
                                                  color: Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.3,
                                                  ),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (!_showPercentage)
                                          Text(
                                            'الهدف: $_target',
                                            style: TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 20,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (_showNextDhikr && _count < _target)
                                      Positioned(
                                        bottom: 40,
                                        left: 20,
                                        right: 20,
                                        child: Text(
                                          _adhkar[(_currentDhikrIndex + 1) %
                                              _adhkar.length],
                                          style: TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 16,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ---------------------------------------------------------
                    // BOTTOM CONTROLS
                    // ---------------------------------------------------------

                    Container(
                      margin: const EdgeInsets.all(
                        20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF2C3E50,
                        ).withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _showResetDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8837C,
                                ),
                                borderRadius: BorderRadius.circular(
                                  25,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'تصفير',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showTargetDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4AF37,
                                ),
                                borderRadius: BorderRadius.circular(
                                  25,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    color: Color(
                                      0xFF1B5E20,
                                    ),
                                    size: 22,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    _showArabicNumbers
                                        ? _toArabicNumbers(
                                            _target,
                                          )
                                        : _target.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      color: Color(
                                        0xFF1B5E20,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showStatsDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.format_list_numbered,
                                    color: Color(
                                      0xFFD4AF37,
                                    ),
                                    size: 22,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                ],
                              ),
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
    );
  }

  // ===========================================================================
  // APP BAR BUTTON
  // ===========================================================================

  Widget _buildAppBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.25,
          ),
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.4,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }
}

// =============================================================================
// STAR PARTICLE
// =============================================================================

class _StarParticle {
  final double left;
  final double top;
  final double size;

  const _StarParticle({
    required this.left,
    required this.top,
    required this.size,
  });
}

// =============================================================================
// ARC PROGRESS
// =============================================================================

class ArcProgressPainter extends CustomPainter {
  final double progress;
  final double arcAnimation;

  const ArcProgressPainter({
    required this.progress,
    required this.arcAnimation,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius = size.width / 2 - 15;

    final Paint bgPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.15,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      bgPaint,
    );

    if (progress <= 0) {
      return;
    }

    final Paint progressPaint = Paint()
      ..color = const Color(
        0xFFD4AF37,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * math.pi * progress * arcAnimation;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant ArcProgressPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.arcAnimation != arcAnimation;
  }
}
