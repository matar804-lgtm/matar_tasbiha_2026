import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:upgrader/upgrader.dart';
import 'screens/splash_screen.dart';
import 'services/prayer_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults({
        'welcome_message': 'مرحباً بك في تطبيق تسبيحة',
        'show_ramadan_banner': false,
        'maintenance_mode': false,
      });
      await remoteConfig.fetchAndActivate();

      // ✅ تهيئة خدمة إشعارات الصلاة فقط (بدون workmanager)
      try {
        await PrayerNotificationService.init();
        await PrayerNotificationService.requestPermissions();
        await PrayerNotificationService.checkAndUpdateIfNeeded();
      } catch (e) {
        print('⚠️ خطأ في تهيئة إشعارات الصلاة: $e');
      }
    } catch (e) {
      print('⚠️ خطأ في تهيئة الخدمات: $e');
    }
  }

  runApp(const MyApp());
}

class ArabicUpgraderMessages extends UpgraderMessages {
  @override
  String get buttonTitleIgnore => 'تجاهل';
  @override
  String get buttonTitleLater => 'لاحقاً';
  @override
  String get buttonTitleUpdate => 'تحديث الآن';
  @override
  String get prompt =>
      'يتوفر تحديث جديد للتطبيق. يرجى التحديث للحصول على أفضل تجربة.';
  @override
  String get title => 'تحديث متاح';
  @override
  String get releaseNotes => 'تم إصلاح بعض الأخطاء وإضافة تحسينات جديدة.';
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics? analytics =
      kIsWeb ? null : FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        messages: ArabicUpgraderMessages(),
        debugDisplayAlways: false, // ✅ معطل للرفع النهائي
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'تطبيق تسبيحة',
        navigatorObservers: [
          if (analytics != null)
            FirebaseAnalyticsObserver(analytics: analytics!),
        ],
        theme: ThemeData(
          primaryColor: const Color(0xFF1B5E20),
          scaffoldBackgroundColor: const Color(0xFF0A0E27),
          fontFamily: 'Amiri',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4AF37),
            brightness: Brightness.dark,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
