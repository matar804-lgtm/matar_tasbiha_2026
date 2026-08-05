import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class EmailHelper {
  static const String studioEmail = 'appnest.studio01@gmail.com';

  /// فتح تطبيق الإيميل مع تعبئة البيانات مسبقاً
  static Future<void> sendEmail({
    required BuildContext context,
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: studioEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // ✅ الإصلاح: التحقق من mounted قبل استخدام context بعد await
        if (context.mounted) {
          _showError(
              context, 'لا يوجد تطبيق بريد إلكتروني مثبت على هذا الجهاز.');
        }
      }
    } catch (e) {
      // ✅ الإصلاح: التحقق من mounted قبل استخدام context بعد await
      if (context.mounted) {
        _showError(context, 'حدث خطأ أثناء فتح تطبيق البريد: $e');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // ✅ إضافة لتحسين المظهر
      ),
    );
  }
}
