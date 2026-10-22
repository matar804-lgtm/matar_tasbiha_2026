import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/login_screen.dart';
import 'services/app_theme_controller.dart';
import 'services/notification_service.dart';
import 'services/prayer_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تشغيل Flutter مباشرة وعدم انتظار أي خدمة خارجية.
  runApp(
    const TasbihaApp(),
  );
}

class TasbihaApp extends StatefulWidget {
  const TasbihaApp({
    super.key,
  });

  @override
  State<TasbihaApp> createState() => _TasbihaAppState();
}

class _TasbihaAppState extends State<TasbihaApp> {
  final AppThemeController _themeController = AppThemeController.instance;

  @override
  void initState() {
    super.initState();

    // تحميل الوضع المحفوظ.
    _themeController.load();

    // الخدمات خارج مسار الإقلاع.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _initializeServices();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ===========================================================================
  // SERVICES
  // ===========================================================================

  Future<void> _initializeServices() async {
    // -------------------------------------------------------------------------
    // Notification Service
    // -------------------------------------------------------------------------

    try {
      await NotificationService.init();
    } catch (e, stackTrace) {
      debugPrint(
        'Notification initialization failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // Prayer Notification Service
    // -------------------------------------------------------------------------

    try {
      await PrayerNotificationService.init();
      await PrayerNotificationService.checkAndUpdateIfNeeded();
    } catch (e, stackTrace) {
      debugPrint(
        'Prayer notification initialization failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // Notification Permission
    // -------------------------------------------------------------------------

    try {
      await Permission.notification.request();
    } catch (e, stackTrace) {
      debugPrint(
        'Notification permission failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // Exact Alarm Permission
    //
    // permission_handler لا يدعم scheduleExactAlarm على Web.
    // لذلك لا يتم استدعاؤه على Chrome، بينما يبقى فعالًا على المنصات
    // التي تدعمه مثل Android.
    // -------------------------------------------------------------------------

    if (!kIsWeb) {
      try {
        final PermissionStatus status =
            await Permission.scheduleExactAlarm.status;

        if (!status.isGranted) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (e, stackTrace) {
        debugPrint(
          'Exact alarm permission failed: $e',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    }

    await PrayerNotificationService.schedulePrayerNotifications();
  }

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Amiri',
      scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1B342B),
        secondary: Color(0xFFD4AF37),
        surface: Colors.white,
        error: Color(0xFFD32F2F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1B342B),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F3F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const Color(
                0xFFD4AF37,
              );
            }

            return Colors.grey;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const Color(
                0xFFD4AF37,
              ).withValues(
                alpha: 0.35,
              );
            }

            return Colors.black12;
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Amiri',
      scaffoldBackgroundColor: const Color(0xFF0A201A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD4AF37),
        secondary: Color(0xFFC9B896),
        surface: Color(0xFF132A22),
        error: Color(0xFFE8837C),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B342B),
        foregroundColor: Color(0xFFD4AF37),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF132A22),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF132A22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const Color(
                0xFFD4AF37,
              );
            }

            return const Color(
              0xFF9AB09F,
            );
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const Color(
                0xFFD4AF37,
              ).withValues(
                alpha: 0.40,
              );
            }

            return const Color(
              0xFF2A4A3D,
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // APP
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (
        context,
        _,
      ) {
        return MaterialApp(
          title: 'تطبيق تسبيحة',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: _themeController.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
