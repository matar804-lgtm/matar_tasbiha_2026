import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();

    // ✅ التحقق من صحة الإيميل فقط إذا قام المستخدم بكتابته
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _errorMessage = 'يرجى إدخال بريد إلكتروني صحيح');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();

    // ✅ حفظ الإيميل فقط إذا لم يكن فارغاً
    if (email.isNotEmpty) {
      await prefs.setString('user_email', email);
    }

    if (mounted) {
      HapticFeedback.mediumImpact();

      // رسالة ترحيبية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            email.isEmpty
                ? 'أهلاً بك زائرنا الكريم، نتمنى لك تجربة مفيدة'
                : 'شكراً لثقتك واختيارك تطبيق التسبيح، نحن هنا لنقدم لك أفضل خدمة',
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 14),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A201A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A201A), Color(0xFF132A22), Color(0xFF0A201A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                    border:
                        Border.all(color: const Color(0xFFF0E0B5), width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: const Icon(Icons.mosque_rounded,
                      color: Color(0xFF0A201A), size: 50),
                ),
                const SizedBox(height: 30),
                const Text(
                  'مرحباً بك أخي المسلم',
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'يمكنك إدخال بريدك الإلكتروني لتخصيص تجربتك،\nأو المتابعة مباشرة كزائر',
                  style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      fontFamily: 'Amiri', color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني (اختياري)',
                    hintStyle: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFFD4AF37)),
                    filled: true,
                    fillColor: const Color(0xFF1B342B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Color(0xFFD4AF37), width: 2),
                    ),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(
                        fontFamily: 'Amiri', color: Color(0xFFE8837C)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Color(0xFF0A201A), strokeWidth: 3))
                        : const Text('متابعة',
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                color: Color(0xFF0A201A),
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
                const Text('AppNest Studio © 2026',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white54,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
