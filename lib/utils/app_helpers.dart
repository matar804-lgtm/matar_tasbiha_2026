import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHelpers {
  // ✅ 1. نظام التقييم داخل التطبيق (يعمل بعد 10 استخدامات)
  static Future<void> requestReviewIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final appOpenCount = prefs.getInt('app_open_count') ?? 0;
    final hasReviewed = prefs.getBool('has_reviewed') ?? false;

    await prefs.setInt('app_open_count', appOpenCount + 1);

    if (appOpenCount >= 10 && !hasReviewed) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        await prefs.setBool('has_reviewed', true);
      }
    }
  }

  // ✅ 2. زر مشاركة التطبيق
  static Future<void> shareApp() async {
    await Share.share(
      '🕌 تطبيق تسبيحة - رفيقك الروحاني اليومي\n\n'
      'تسبيح، قرآن، أذكار، ومواقيت صلاة بتصميم أنيق.\n\n'
      'حمّله الآن من Google Play:\n'
      'https://play.google.com/store/apps/details?id=com.appnest.tasbiha',
      subject: 'تطبيق تسبيحة - رفيقك الروحاني',
    );
    FirebaseAnalytics.instance.logEvent(name: 'app_shared');
  }

  // ✅ 3. قراءة إعدادات Remote Config
  static String getWelcomeMessage() {
    return FirebaseRemoteConfig.instance.getString('welcome_message');
  }

  static bool shouldShowRamadanBanner() {
    return FirebaseRemoteConfig.instance.getBool('show_ramadan_banner');
  }

  static bool isMaintenanceMode() {
    return FirebaseRemoteConfig.instance.getBool('maintenance_mode');
  }

  // ✅ 4. عرض نافذة التقييم يدوياً (للاختبار أو من القائمة)
  static void showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B5E20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.star, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Text(
              'هل أعجبك التطبيق؟',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFFD4AF37),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'إذا كنت تستمتع باستخدام تطبيق تسبيحة، '
          'نرجو منك تقييمه على متجر Google Play. '
          'تقييمك يساعدنا على التطوير والاستمرار.',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'لاحقاً',
              style: TextStyle(
                  fontFamily: 'Amiri', color: Colors.white70, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              }
            },
            child: const Text(
              'قيّم الآن ⭐',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
