import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_settings_model.dart';
import 'prayer_settings_service.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // ============================================================
  // الإعدادات
  // ============================================================

  static const String _noticeChannelId = 'prayer_notice_v4';

  static const String _vibrateChannelId = 'prayer_vibrate_v4';

  static const String _soundChannelPrefix = 'adhan_sound_v4_';

  static const int _notificationBaseId = 3000;

  static const Duration _adhanDelay = Duration(seconds: 3);

  static const int _daysToSchedule = 3;

  // ============================================================
  // 1. التهيئة
  // ============================================================

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      // ----------------------------------------------------------
      // تهيئة المناطق الزمنية
      // ----------------------------------------------------------

      tz_data.initializeTimeZones();

      await _setDeviceTimezone();

      // ----------------------------------------------------------
      // إعداد Android
      // ----------------------------------------------------------

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _notifications.initialize(settings);

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // ----------------------------------------------------------
      // قناة الإشعار العادي
      // ----------------------------------------------------------

      const AndroidNotificationChannel noticeChannel =
          AndroidNotificationChannel(
        _noticeChannelId,
        'تنبيهات مواقيت الصلاة',
        description: 'إشعار عند دخول وقت الصلاة',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      );

      // ----------------------------------------------------------
      // قناة الاهتزاز
      // ----------------------------------------------------------

      const AndroidNotificationChannel vibrateChannel =
          AndroidNotificationChannel(
        _vibrateChannelId,
        'تنبيهات الصلاة بالاهتزاز',
        description: 'تنبيه الصلاة بالاهتزاز فقط',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      );

      await androidPlugin?.createNotificationChannel(
        noticeChannel,
      );

      await androidPlugin?.createNotificationChannel(
        vibrateChannel,
      );

      _isInitialized = true;

      print('✅ تم تهيئة خدمة الإشعارات');
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  // ============================================================
  // 2. ضبط المنطقة الزمنية
  // ============================================================

  static Future<void> _setDeviceTimezone() async {
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();

      final tz.Location location = tz.getLocation(timezoneName);

      tz.setLocalLocation(location);

      print('🌍 المنطقة الزمنية: $timezoneName');
    } catch (e) {
      print('⚠️ تعذر تحديد المنطقة الزمنية للجهاز: $e');

      try {
        tz.setLocalLocation(tz.local);
      } catch (_) {}
    }
  }

  // ============================================================
  // 3. طلب الصلاحيات
  // ============================================================

  static Future<bool> requestPermissions() async {
    try {
      await init();

      // ----------------------------------------------------------
      // صلاحية الموقع
      // ----------------------------------------------------------

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('❌ صلاحية الموقع مرفوضة');
        return false;
      }

      // ----------------------------------------------------------
      // صلاحية الإشعارات
      // ----------------------------------------------------------

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? notificationPermission =
          await androidPlugin?.requestNotificationsPermission();

      // ----------------------------------------------------------
      // صلاحية Exact Alarm
      // ----------------------------------------------------------

      final bool? exactAlarmPermission =
          await androidPlugin?.requestExactAlarmsPermission();

      print(
        '🔔 صلاحية الإشعارات: $notificationPermission',
      );

      print(
        '⏰ صلاحية Exact Alarm: $exactAlarmPermission',
      );

      return notificationPermission != false;
    } catch (e) {
      print('❌ خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  // ============================================================
  // 4. جدولة مواقيت الصلاة
  // ============================================================

  static Future<void> schedulePrayerNotifications() async {
    try {
      await init();

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final bool enabled = prefs.getBool('enable_notifications') ??
          prefs.getBool('prayer_notifications') ??
          true;

      if (!enabled) {
        print('🔕 إشعارات الصلاة معطلة');
        await _cancelPrayerNotifications();
        return;
      }

      // ----------------------------------------------------------
      // الإعدادات المحفوظة هي المصدر الأساسي للحساب والجدولة.
      // إذا لم تكن موجودة نستخدم GPS كخطة توافقية مع الإصدارات السابقة.
      // ----------------------------------------------------------
      final PrayerSettings? savedSettings =
          await PrayerSettingsService.loadPrayerSettings();

      Coordinates coordinates;
      CalculationParameters params;

      if (savedSettings != null) {
        coordinates = Coordinates(
          savedSettings.selectedCity.latitude,
          savedSettings.selectedCity.longitude,
        );
        params = PrayerSettingsService.getCalculationParameters(
          savedSettings,
        );

        print(
          '📍 جدولة الصلاة للموقع المحفوظ: '
          '${savedSettings.selectedCity.name} - '
          '${savedSettings.selectedCountry.label}',
        );
        print('🕌 المذهب: ${savedSettings.selectedSchool.label}');
        print('⏰ الجهة: ${savedSettings.selectedAuthority.label}');
      } else {
        // --------------------------------------------------------
        // توافق مع النسخ السابقة عند عدم وجود إعدادات محفوظة.
        // --------------------------------------------------------
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('❌ لا توجد صلاحية للموقع');
          return;
        }

        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        coordinates = Coordinates(
          position.latitude,
          position.longitude,
        );

        params = PrayerSettingsService.getCalculationParameters(
            PrayerSettingsService.getDefaultSettings());

        print(
          '📍 موقع GPS: ${position.latitude}, ${position.longitude}',
        );
      }

      // ----------------------------------------------------------
      // إلغاء الجدولة القديمة
      // ----------------------------------------------------------
      await _cancelPrayerNotifications();

      // ----------------------------------------------------------
      // إعداد الصوت
      // ----------------------------------------------------------
      final bool enableAdhan = prefs.getBool('enable_adhan') ?? true;

      final String selectedSoundId =
          prefs.getString('selected_app_sound_id') ?? 'adhan_makkah';

      print('🎵 الصوت المختار: $selectedSoundId');

      final String? customSoundPath = prefs.getString('custom_sound_path');
      if (customSoundPath != null && customSoundPath.isNotEmpty) {
        print('🎵 ملف الصوت المخصص: $customSoundPath');
      }

      // ----------------------------------------------------------
      // جدولة الأيام القادمة
      // ----------------------------------------------------------
      for (int dayOffset = 0; dayOffset < _daysToSchedule; dayOffset++) {
        final DateTime targetDate = DateTime.now().add(
          Duration(days: dayOffset),
        );

        final DateComponents date = DateComponents(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );

        final PrayerTimes prayerTimes = savedSettings != null
            ? PrayerSettingsService.calculatePrayerTimes(
                savedSettings,
                date: targetDate,
              )
            : PrayerTimes(
                coordinates,
                date,
                params,
              );

        await _schedulePrayer(
          prayer: Prayer.fajr,
          time: prayerTimes.fajr,
          dayOffset: dayOffset,
          prayerIndex: 0,
          selectedSoundId: selectedSoundId,
          enableAdhan: enableAdhan,
        );

        await _schedulePrayer(
          prayer: Prayer.dhuhr,
          time: prayerTimes.dhuhr,
          dayOffset: dayOffset,
          prayerIndex: 1,
          selectedSoundId: selectedSoundId,
          enableAdhan: enableAdhan,
        );

        await _schedulePrayer(
          prayer: Prayer.asr,
          time: prayerTimes.asr,
          dayOffset: dayOffset,
          prayerIndex: 2,
          selectedSoundId: selectedSoundId,
          enableAdhan: enableAdhan,
        );

        await _schedulePrayer(
          prayer: Prayer.maghrib,
          time: prayerTimes.maghrib,
          dayOffset: dayOffset,
          prayerIndex: 3,
          selectedSoundId: selectedSoundId,
          enableAdhan: enableAdhan,
        );

        await _schedulePrayer(
          prayer: Prayer.isha,
          time: prayerTimes.isha,
          dayOffset: dayOffset,
          prayerIndex: 4,
          selectedSoundId: selectedSoundId,
          enableAdhan: enableAdhan,
        );
      }

      await prefs.setInt(
        'last_prayer_update',
        DateTime.now().millisecondsSinceEpoch,
      );

      print('✅ تم جدولة مواقيت الصلاة بنجاح');
    } catch (e, stackTrace) {
      print('❌ خطأ في جدولة الصلاة: $e');
      print(stackTrace);
    }
  }

  // ============================================================
  // 5. جدولة صلاة واحدة
  // ============================================================

  static Future<void> _schedulePrayer({
    required Prayer prayer,
    required DateTime? time,
    required int dayOffset,
    required int prayerIndex,
    required String selectedSoundId,
    required bool enableAdhan,
  }) async {
    if (time == null) {
      return;
    }

    final DateTime now = DateTime.now();

    // لا نضع إشعاراً في الماضي
    if (time.isBefore(now)) {
      return;
    }

    final tz.TZDateTime prayerTime = tz.TZDateTime.from(
      time,
      tz.local,
    );

    final int notificationId =
        _notificationBaseId + (dayOffset * 100) + (prayerIndex * 2);

    final int adhanId = notificationId + 1;

    final String prayerName = _getPrayerName(prayer);

    // ==========================================================
    // زر الأذان وحده يتحكم في تشغيل الصوت.
    if (!enableAdhan) {
      await _scheduleNoticeNotification(
        id: notificationId,
        prayerName: prayerName,
        scheduledDate: prayerTime,
      );
      return;
    }
    // إشعار دخول وقت الصلاة
    // ==========================================================

    await _scheduleNoticeNotification(
      id: notificationId,
      prayerName: prayerName,
      scheduledDate: prayerTime,
    );

    // ==========================================================
    // تشغيل الأذان بعد 3 ثوانٍ
    // ==========================================================

    final tz.TZDateTime adhanTime = prayerTime.add(_adhanDelay);

    // ==========================================================
    // تحديد الصوت
    // ==========================================================

    final String rawSound = _getRawSoundName(selectedSoundId);

    final String channelId = '$_soundChannelPrefix$rawSound';

    // إنشاء قناة الصوت
    await _createSoundChannel(
      channelId: channelId,
      rawSound: rawSound,
    );

    // جدولة الأذان
    await _scheduleAdhanNotification(
      id: adhanId,
      prayerName: prayerName,
      scheduledDate: adhanTime,
      channelId: channelId,
      rawSound: rawSound,
      isTakbeer: false,
    );
  }

  // ============================================================
  // 6. إشعار دخول وقت الصلاة
  // ============================================================

  static Future<void> _scheduleNoticeNotification({
    required int id,
    required String prayerName,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _noticeChannelId,
      'تنبيهات الصلاة',
      channelDescription: 'إشعار عند دخول وقت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'حان وقت الصلاة 🕌',
      'حان الآن وقت صلاة $prayerName',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // 7. إشعار صامت
  // ============================================================

  static Future<void> _scheduleSilentNotification({
    required int id,
    required String prayerName,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _noticeChannelId,
      'تنبيهات الصلاة',
      channelDescription: 'إشعار الصلاة بدون صوت',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'حان وقت الصلاة',
      'حان الآن وقت صلاة $prayerName',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // 8. إشعار الاهتزاز فقط
  // ============================================================

  static Future<void> _scheduleVibrationNotification({
    required int id,
    required String prayerName,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _vibrateChannelId,
      'تنبيهات الصلاة بالاهتزاز',
      channelDescription: 'تنبيه الصلاة بالاهتزاز',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'حان وقت الصلاة',
      'حان الآن وقت صلاة $prayerName',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // 9. إشعار الأذان / التكبير
  // ============================================================

  static Future<void> _scheduleAdhanNotification({
    required int id,
    required String prayerName,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String rawSound,
    required bool isTakbeer,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      isTakbeer ? 'التكبير' : 'الأذان',
      channelDescription: isTakbeer
          ? 'تشغيل التكبير عند دخول وقت الصلاة'
          : 'تشغيل الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        rawSound,
      ),
      enableVibration: false,
      autoCancel: true,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      isTakbeer ? 'تكبير صلاة $prayerName 🕌' : 'أذان صلاة $prayerName 🕌',
      isTakbeer
          ? 'حان الآن وقت صلاة $prayerName'
          : 'حان الآن وقت صلاة $prayerName',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // 10. إنشاء قناة الأذان / التكبير
  // ============================================================

  static Future<void> _createSoundChannel({
    required String channelId,
    required String rawSound,
  }) async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool isTakbeer = rawSound == 'takbeer';

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      isTakbeer ? 'التكبير' : 'الأذان',
      description:
          isTakbeer ? 'قناة تشغيل صوت التكبير' : 'قناة تشغيل صوت الأذان',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        rawSound,
      ),
      enableVibration: false,
      showBadge: true,
    );

    await androidPlugin?.createNotificationChannel(
      channel,
    );
  }

  // ============================================================
  // 11. أسماء ملفات الأذان
  // ============================================================

  static String _getRawSoundName(
    String soundId,
  ) {
    switch (soundId) {
      case 'adhan_makkah':
        return 'adhan_makkah';

      case 'almadenh':
        return 'almadenh';

      case 'alquds':
        return 'alquds';

      case 'mshary':
        return 'mshary';

      case 'abd_albaset':
        return 'abd_albaset';

      case 'takbeer':
        return 'takbeer';

      default:
        return 'adhan_makkah';
    }
  }

  // ============================================================
  // 12. إلغاء إشعارات الصلاة
  // ============================================================

  static Future<void> _cancelPrayerNotifications() async {
    // ----------------------------------------------------------
    // إشعارات الإصدارات القديمة
    // ----------------------------------------------------------

    for (int id = 1; id <= 100; id++) {
      await _notifications.cancel(id);
    }

    // ----------------------------------------------------------
    // إشعارات الإصدار الحالي
    // ----------------------------------------------------------

    for (int dayOffset = 0; dayOffset < _daysToSchedule; dayOffset++) {
      for (int prayerIndex = 0; prayerIndex < 5; prayerIndex++) {
        final int notificationId =
            _notificationBaseId + (dayOffset * 100) + (prayerIndex * 2);

        await _notifications.cancel(
          notificationId,
        );

        await _notifications.cancel(
          notificationId + 1,
        );
      }
    }
  }

  // ============================================================
  // 13. تحديث المواقيت عند بداية يوم جديد
  // ============================================================

  static Future<void> checkAndUpdateIfNeeded() async {
    try {
      await init();

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final int lastUpdate = prefs.getInt('last_prayer_update') ?? 0;

      // أول تشغيل
      if (lastUpdate == 0) {
        await schedulePrayerNotifications();
        return;
      }

      final DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(
        lastUpdate,
      );

      final DateTime now = DateTime.now();

      final bool newDay = lastDate.year != now.year ||
          lastDate.month != now.month ||
          lastDate.day != now.day;

      if (newDay) {
        await schedulePrayerNotifications();
      }
    } catch (e) {
      print(
        '❌ خطأ في تحديث مواقيت الصلاة: $e',
      );
    }
  }

  // ============================================================
  // 14. تفعيل / تعطيل الإشعارات
  // ============================================================

  static Future<void> setNotificationsEnabled(
    bool enabled,
  ) async {
    await init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'prayer_notifications',
      enabled,
    );

    if (enabled) {
      await schedulePrayerNotifications();
    } else {
      await _cancelPrayerNotifications();
    }
  }

  // ============================================================
  // 15. معرفة حالة الإشعارات
  // ============================================================

  static Future<bool> isNotificationsEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
          'prayer_notifications',
        ) ??
        true;
  }

  // ============================================================
  // 16. حفظ وضع الصوت
  // ============================================================

  static Future<void> setSoundMode(
    SoundOptionMode mode,
  ) async {
    await init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'sound_mode',
      mode.index,
    );

    print('🔊 تم تغيير وضع الصوت إلى: $mode');

    final bool enabled = prefs.getBool('prayer_notifications') ?? true;

    if (enabled) {
      await schedulePrayerNotifications();
    }
  }

  // ============================================================
  // 17. معرفة وضع الصوت الحالي
  // ============================================================

  static Future<SoundOptionMode> getSoundMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int index =
        prefs.getInt('sound_mode') ?? SoundOptionMode.appSound.index;

    if (index >= 0 && index < SoundOptionMode.values.length) {
      return SoundOptionMode.values[index];
    }

    return SoundOptionMode.appSound;
  }

  // ============================================================
  // 18. حفظ صوت الأذان المختار
  // ============================================================

  static Future<void> setSelectedSound(
    String soundId,
  ) async {
    await init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'selected_app_sound_id',
      soundId,
    );

    print('🎵 تم اختيار صوت: $soundId');

    final bool enabled = prefs.getBool('prayer_notifications') ?? true;

    if (enabled) {
      await schedulePrayerNotifications();
    }
  }

  // ============================================================
  // 19. معرفة صوت الأذان الحالي
  // ============================================================

  static Future<String> getSelectedSound() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(
          'selected_app_sound_id',
        ) ??
        'adhan_makkah';
  }

  // ============================================================
  // 20. أسماء الصلوات
  // ============================================================

  static String _getPrayerName(
    Prayer prayer,
  ) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';

      case Prayer.dhuhr:
        return 'الظهر';

      case Prayer.asr:
        return 'العصر';

      case Prayer.maghrib:
        return 'المغرب';

      case Prayer.isha:
        return 'العشاء';

      default:
        return '';
    }
  }
}

// ================================================================
// أوضاع الصوت
// ================================================================

enum SoundOptionMode {
  // تشغيل أحد أصوات الأذان الموجودة في التطبيق
  appSound,

  // ملف مخصص - محفوظ للتوافق مع النظام الحالي
  customFile,

  // التكبير فقط
  takbeer,

  // اهتزاز فقط
  vibrateOnly,

  // بدون صوت وبدون اهتزاز
  silent,
}
