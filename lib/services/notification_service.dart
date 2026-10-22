import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _persistentChannelId = 'persistent_channel_v2';
  static const String _prayerAlertChannelId = 'prayer_alert_channel_v2';
  static const String _azanChannelId = 'azan_channel_v2';
  static const String _dhikrChannelId = 'dhikr_channel_v2';

  static bool _initialized = false;
  static String? _lastPersistentKey;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );

    await _createNotificationChannels();

    _initialized = true;
  }

  static Future<void> _configureLocalTimezone() async {
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timezoneName),
      );

      debugPrint(
        'Notification timezone: $timezoneName',
      );
    } catch (e) {
      debugPrint(
        'تعذر تحديد المنطقة الزمنية للجهاز: $e',
      );
    }
  }

  // ===========================================================================
  // CHANNELS
  // ===========================================================================

  static Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) {
      return;
    }

    const AndroidNotificationChannel persistentChannel =
        AndroidNotificationChannel(
      _persistentChannelId,
      'مواقيت الصلاة',
      description: 'إشعار يوضح الصلاة القادمة والوقت المتبقي',
      importance: Importance.low,
    );

    const AndroidNotificationChannel prayerAlertChannel =
        AndroidNotificationChannel(
      _prayerAlertChannelId,
      'تنبيهات الصلاة',
      description: 'تنبيه قبل موعد الصلاة',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel azanChannel = AndroidNotificationChannel(
      _azanChannelId,
      'مواقيت الأذان',
      description: 'صوت الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'adhan_makkah',
      ),
    );

    const AndroidNotificationChannel dhikrChannel = AndroidNotificationChannel(
      _dhikrChannelId,
      'تذكير بالأذكار',
      description: 'تذكيرات إيمانية خلال اليوم',
      importance: Importance.high,
      playSound: false,
    );

    await android.createNotificationChannel(
      persistentChannel,
    );

    await android.createNotificationChannel(
      prayerAlertChannel,
    );

    await android.createNotificationChannel(
      azanChannel,
    );

    await android.createNotificationChannel(
      dhikrChannel,
    );
  }

  // ===========================================================================
  // PERMISSIONS
  // ===========================================================================

  static Future<bool> requestNotificationPermission() async {
    try {
      final PermissionStatus status = await Permission.notification.request();

      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint(
        'خطأ في إذن الإشعارات: $e',
      );
      return false;
    }
  }

  static Future<bool> requestExactAlarmPermission() async {
    try {
      final PermissionStatus currentStatus =
          await Permission.scheduleExactAlarm.status;

      if (currentStatus.isGranted) {
        return true;
      }

      final PermissionStatus requestedStatus =
          await Permission.scheduleExactAlarm.request();

      return requestedStatus.isGranted;
    } catch (e) {
      debugPrint(
        'خطأ في إذن المنبهات الدقيقة: $e',
      );
      return false;
    }
  }

  static Future<bool> canUseExactAlarms() async {
    try {
      final PermissionStatus status =
          await Permission.scheduleExactAlarm.status;

      return status.isGranted;
    } catch (e) {
      debugPrint(
        'تعذر التحقق من Exact Alarm: $e',
      );
      return false;
    }
  }

  // ===========================================================================
  // PERSISTENT NOTIFICATION
  // ===========================================================================

  static Future<void> showPersistentNotification(
    String nextPrayer,
    String timeRemaining,
  ) async {
    await init();

    final String key = '$nextPrayer|$timeRemaining';

    if (_lastPersistentKey == key) {
      return;
    }

    _lastPersistentKey = key;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _persistentChannelId,
      'مواقيت الصلاة',
      channelDescription: 'إشعار يوضح الصلاة القادمة والوقت المتبقي',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999,
      'الصلاة القادمة: $nextPrayer',
      'متبقي: $timeRemaining',
      details,
    );
  }

  // ===========================================================================
  // PRAYER NOTIFICATIONS
  // ===========================================================================

  static Future<void> schedulePrayerNotifications(
    String prayerName,
    DateTime prayerTime,
  ) async {
    await init();

    final DateTime now = DateTime.now();

    if (!prayerTime.isAfter(now)) {
      return;
    }

    final tz.TZDateTime tzPrayerTime = tz.TZDateTime.from(
      prayerTime,
      tz.local,
    );

    final tz.TZDateTime tzAlertTime = tzPrayerTime.subtract(
      const Duration(seconds: 15),
    );

    final bool exactAllowed = await canUseExactAlarms();

    final AndroidScheduleMode scheduleMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    // -------------------------------------------------------------------------
    // قبل الصلاة
    // -------------------------------------------------------------------------

    if (tzAlertTime.isAfter(
      tz.TZDateTime.now(tz.local),
    )) {
      const AndroidNotificationDetails alertDetails =
          AndroidNotificationDetails(
        _prayerAlertChannelId,
        'تنبيهات الصلاة',
        channelDescription: 'تنبيه قبل موعد الصلاة',
        importance: Importance.high,
        priority: Priority.high,
        onlyAlertOnce: true,
      );

      await _notificationsPlugin.zonedSchedule(
        _buildPrayerNotificationId(
          prayerTime,
          0,
        ),
        'قرب موعد الأذان',
        'تبقى 15 ثانية على صلاة $prayerName',
        tzAlertTime,
        const NotificationDetails(
          android: alertDetails,
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // -------------------------------------------------------------------------
    // وقت الصلاة
    // -------------------------------------------------------------------------

    const AndroidNotificationDetails azanDetails = AndroidNotificationDetails(
      _azanChannelId,
      'مواقيت الأذان',
      channelDescription: 'صوت الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'adhan_makkah',
      ),
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    await _notificationsPlugin.zonedSchedule(
      _buildPrayerNotificationId(
        prayerTime,
        1,
      ),
      'حان الآن موعد الصلاة',
      'حان الآن موعد صلاة $prayerName، تقبل الله طاعتكم',
      tzPrayerTime,
      const NotificationDetails(
        android: azanDetails,
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ===========================================================================
  // RANDOM DHIKR
  // ===========================================================================

  static Future<void> scheduleRandomDhikrNotifications() async {
    await init();

    final List<String> adhkars = [
      'أذكر الله',
      'صل على النبي محمد ﷺ',
      'سبحان الله وبحمده، سبحان الله العظيم',
      'الله أكبر',
      'لا حول ولا قوة إلا بالله',
      'استغفر الله العظيم وأتوب إليه',
    ];

    final Random random = Random();
    final DateTime now = DateTime.now();

    final bool exactAllowed = await canUseExactAlarms();

    final AndroidScheduleMode scheduleMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const AndroidNotificationDetails dhikrDetails = AndroidNotificationDetails(
      _dhikrChannelId,
      'تذكير بالأذكار',
      channelDescription: 'تذكيرات إيمانية خلال اليوم',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
    );

    for (int i = 0; i < 4; i++) {
      final int randomMinutes = 60 + random.nextInt(600);

      final DateTime scheduleTime = now.add(
        Duration(
          minutes: randomMinutes,
        ),
      );

      final tz.TZDateTime tzTime = tz.TZDateTime.from(
        scheduleTime,
        tz.local,
      );

      final String randomDhikr = adhkars[random.nextInt(
        adhkars.length,
      )];

      await _notificationsPlugin.zonedSchedule(
        1000 + i,
        'تذكير إيماني',
        randomDhikr,
        tzTime,
        const NotificationDetails(
          android: dhikrDetails,
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ===========================================================================
  // CANCEL
  // ===========================================================================

  static Future<void> cancelAllNotifications() async {
    await init();

    await _notificationsPlugin.cancelAll();

    _lastPersistentKey = null;
  }

  static Future<void> cancelPersistentNotification() async {
    await init();

    await _notificationsPlugin.cancel(
      999,
    );

    _lastPersistentKey = null;
  }

  // ===========================================================================
  // IDS
  // ===========================================================================

  static int _buildPrayerNotificationId(
    DateTime prayerTime,
    int offset,
  ) {
    final int minutes =
        prayerTime.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;

    final int normalized = minutes.abs() % 900000000;

    return normalized + offset;
  }
}
