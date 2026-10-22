import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = true;
  bool _isNavigating = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOGIN STATUS
  // ===========================================================================

  Future<void> _checkLoginStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String savedEmail = prefs.getString('user_email')?.trim() ?? '';

      if (!mounted) {
        return;
      }

      if (savedEmail.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });

        _navigateToMainScreen();
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Login status check failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // ENTER WITH EMAIL
  // ===========================================================================

  Future<void> _saveEmailAndProceed() async {
    final String email = _emailController.text.trim();

    // البريد الإلكتروني اختياري.
    if (email.isEmpty) {
      await _continueAsGuest();
      return;
    }

    // إذا كتب المستخدم بريدًا، يجب أن يكون صحيحًا.
    if (!_isValidEmail(email)) {
      _showError(
        'يرجى إدخال بريد إلكتروني صحيح أو اترك الحقل فارغًا للمتابعة كزائر',
      );
      return;
    }

    if (_isNavigating) {
      return;
    }

    try {
      setState(() {
        _isNavigating = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'user_email',
        email,
      );

      if (!mounted) {
        return;
      }

      HapticFeedback.mediumImpact();

      _navigateToMainScreen();
    } catch (e, stackTrace) {
      debugPrint(
        'Saving email failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isNavigating = false;
      });

      _showError(
        'تعذر حفظ بيانات الدخول. حاول مرة أخرى.',
      );
    }
  }

  // ===========================================================================
  // CONTINUE AS GUEST
  // ===========================================================================

  Future<void> _continueAsGuest() async {
    if (_isNavigating) {
      return;
    }

    try {
      setState(() {
        _isNavigating = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // لا نحفظ بريدًا للمستخدم الزائر.
      await prefs.remove('user_email');

      if (!mounted) {
        return;
      }

      HapticFeedback.mediumImpact();

      _navigateToMainScreen();
    } catch (e, stackTrace) {
      debugPrint(
        'Guest navigation failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isNavigating = false;
      });

      _showError(
        'تعذر فتح التطبيق. حاول مرة أخرى.',
      );
    }
  }

  // ===========================================================================
  // EMAIL VALIDATION
  // ===========================================================================

  bool _isValidEmail(
    String email,
  ) {
    if (email.isEmpty) {
      return false;
    }

    final RegExp emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return emailPattern.hasMatch(email);
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _navigateToMainScreen() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const DashboardScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(
          milliseconds: 450,
        ),
      ),
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
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
      return _buildLoadingScreen();
    }

    return _buildWelcomeAndLoginScreen();
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A201A),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  // ===========================================================================
  // WELCOME + LOGIN
  // ===========================================================================

  Widget _buildWelcomeAndLoginScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A201A),
              Color(0xFF102C23),
              Color(0xFF081912),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 16,
                ),

                // ==========================================================
                // ICON
                // ==========================================================

                _buildAppIcon(),

                const SizedBox(
                  height: 16,
                ),

                // ==========================================================
                // APP NAME
                // ==========================================================

                const Text(
                  'تسبيحة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 42,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                const Text(
                  'رفيقك في ذكر الله',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: Color(0xFFC9B896),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==========================================================
                // GREETING
                // ==========================================================

                _buildGreetingCard(),

                const SizedBox(
                  height: 16,
                ),

                // ==========================================================
                // QURAN VERSE
                // ==========================================================

                _buildVerseCard(),

                const SizedBox(
                  height: 16,
                ),

                // ==========================================================
                // CHARITY CARD
                // ==========================================================

                _buildCharityCard(),

                const SizedBox(
                  height: 22,
                ),

                // ==========================================================
                // LOGIN CARD
                // ==========================================================

                _buildLoginCard(),

                const SizedBox(
                  height: 18,
                ),

                // ==========================================================
                // GUEST
                // ==========================================================

                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _isNavigating ? null : _continueAsGuest,
                    icon: const Icon(
                      Icons.person_outline_rounded,
                    ),
                    label: const Text(
                      'متابعة كزائر',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(
                        0xFFD4AF37,
                      ),
                      side: BorderSide(
                        color: const Color(
                          0xFFD4AF37,
                        ).withValues(
                          alpha: 0.55,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  'البريد الإلكتروني اختياري ويمكنك استخدام التطبيق كزائر.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==========================================================
                // FOOTER
                // ==========================================================

                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // APP ICON
  // ===========================================================================

  Widget _buildAppIcon() {
    return Center(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(
            0xFFD4AF37,
          ).withValues(
            alpha: 0.08,
          ),
          border: Border.all(
            color: const Color(
              0xFFD4AF37,
            ).withValues(
              alpha: 0.65,
            ),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFD4AF37,
              ).withValues(
                alpha: 0.12,
              ),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.mosque_rounded,
          size: 58,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  // ===========================================================================
  // GREETING CARD
  // ===========================================================================

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF132A22,
        ).withValues(
          alpha: 0.90,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: const Color(
            0xFFC9B896,
          ).withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 1,
                color: const Color(
                  0xFFC9B896,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFC9B896),
                size: 13,
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 34,
                height: 1,
                color: const Color(
                  0xFFC9B896,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          const Text(
            'السلام عليكم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: Color(0xFFF0E0B5),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'أهلاً وسهلاً بك في تطبيق تسبيحة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 15,
              color: Color(0xFF9AB09F),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VERSE CARD
  // ===========================================================================

  Widget _buildVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF0D1814,
        ).withValues(
          alpha: 0.85,
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(
            0xFFD4AF37,
          ),
          width: 1.4,
        ),
      ),
      child: const Column(
        children: [
          Text(
            'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 23,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              height: 1.55,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'سورة الرعد - آية 28',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CHARITY CARD
  // ===========================================================================

  Widget _buildCharityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D2817),
            Color(0xFF5D3A1F),
          ],
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: const Color(
            0xFFD4AF37,
          ),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.18,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: Color(0xFFE8837C),
            size: 28,
          ),
          SizedBox(
            height: 7,
          ),
          Text(
            'صدقة جارية',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 21,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 7,
          ),
          Text(
            'عني وعن روح والدي ووالدتي رحمهما الله',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LOGIN CARD
  // ===========================================================================

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF132A22,
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(
            0xFFC9B896,
          ).withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFD4AF37,
                  ).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Color(
                    0xFFD4AF37,
                  ),
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'البريد الإلكتروني',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'اختياري - لحفظ بياناتك',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11,
                        color: Color(
                          0xFF9AB09F,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Amiri',
              fontSize: 15,
            ),
            onSubmitted: (_) {
              _saveEmailAndProceed();
            },
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintStyle: const TextStyle(
                color: Colors.white38,
                fontFamily: 'Amiri',
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(
                  0xFFD4AF37,
                ),
              ),
              filled: true,
              fillColor: const Color(
                0xFF0A201A,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  13,
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  13,
                ),
                borderSide: const BorderSide(
                  color: Color(
                    0xFFD4AF37,
                  ),
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isNavigating ? null : _saveEmailAndProceed,
              icon: _isNavigating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(
                          0xFF0A201A,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                    ),
              label: Text(
                _isNavigating ? 'جاري الدخول...' : 'دخول',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFD4AF37,
                ),
                foregroundColor: const Color(
                  0xFF0A201A,
                ),
                disabledBackgroundColor: const Color(
                  0xFF8E7930,
                ),
                disabledForegroundColor: const Color(
                  0xFF0A201A,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 1,
              color: const Color(
                0xFFC9B896,
              ).withValues(
                alpha: 0.35,
              ),
            ),
            const SizedBox(
              width: 7,
            ),
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFC9B896),
              size: 12,
            ),
            const SizedBox(
              width: 7,
            ),
            Container(
              width: 30,
              height: 1,
              color: const Color(
                0xFFC9B896,
              ).withValues(
                alpha: 0.35,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'صُنع بـ ❤️ لخدمة الإسلام والمسلمين',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Color(0xFF9AB09F),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        const Text(
          'إعداد: محمد مطر - AppNest Studio',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
