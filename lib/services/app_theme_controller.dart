import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance =
      AppThemeController._();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> load() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      _isDarkMode =
          prefs.getBool('is_dark_mode') ?? true;

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint(
        'Theme loading failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setDarkMode(
    bool enabled,
  ) async {
    if (_isDarkMode == enabled) {
      return;
    }

    _isDarkMode = enabled;

    // تحديث التطبيق فورًا.
    notifyListeners();

    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'is_dark_mode',
        enabled,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Theme saving failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> toggle() async {
    await setDarkMode(
      !_isDarkMode,
    );
  }
}