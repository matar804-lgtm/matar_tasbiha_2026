import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // ✅ 1. تهيئة الخدمة (دالة ثابتة)
  static Future<void> init() async {
    if (_isInitialized) return;
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_times_channel',
      'أوقات الصلاة',
      description: 'إشعارات مواقيت الصلاة اليومية',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _isInitialized = true;
  }

  // ✅ 2. طلب الأذونات (دالة ثابتة)
  static Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return true;
  }

  // ✅ 3. جدولة الإشعارات (دالة ثابتة)
  static Future<void> schedulePrayerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('prayer_notifications') ?? true;
    if (!notificationsEnabled) return;

    try {
      await _notifications.cancelAll();

      // ✅ التصحيح 1: استخدام desiredAccuracy لتجنب خطأ locationSettings
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      // ✅ التصحيح 2: تحويل DateTime إلى DateComponents
      final date = DateComponents.from(DateTime.now());
      final coordinates = Coordinates(position.latitude, position.longitude);

      // ✅ التصحيح 3: استخدام muslim_world_league (بأحرف صغيرة وشرطة سفلية)
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes(coordinates, date, params);

      await _scheduleSingleNotification(
          id: 1,
          title: 'صلاة الفجر',
          body: 'حان الآن وقت صلاة الفجر 🌅',
          dateTime: prayerTimes.fajr);
      await _scheduleSingleNotification(
          id: 2,
          title: 'صلاة الظهر',
          body: 'حان الآن وقت صلاة الظهر ☀️',
          dateTime: prayerTimes.dhuhr);
      await _scheduleSingleNotification(
          id: 3,
          title: 'صلاة العصر',
          body: 'حان الآن وقت صلاة العصر 🌤️',
          dateTime: prayerTimes.asr);
      await _scheduleSingleNotification(
          id: 4,
          title: 'صلاة المغرب',
          body: 'حان الآن وقت صلاة المغرب 🌇',
          dateTime: prayerTimes.maghrib);
      await _scheduleSingleNotification(
          id: 5,
          title: 'صلاة العشاء',
          body: 'حان الآن وقت صلاة العشاء 🌙',
          dateTime: prayerTimes.isha);

      await prefs.setInt(
          'last_prayer_update', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('⚠️ خطأ في جدولة إشعارات الصلاة: $e');
    }
  }

  // ✅ 4. جدولة إشعار واحد
  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'أوقات الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة اليومية',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ✅ 5. التحقق من التحديث
  static Future<void> checkAndUpdateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('last_prayer_update') ?? 0;
    final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    final now = DateTime.now();

    final needsUpdate = lastUpdate == 0 ||
        lastUpdateDate.day != now.day ||
        now.difference(lastUpdateDate).inHours >= 24;

    if (needsUpdate) {
      await schedulePrayerNotifications();
    }
  }

  // ✅ 6. تفعيل/تعطيل
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notifications', enabled);
    if (enabled) {
      await schedulePrayerNotifications();
    } else {
      await _notifications.cancelAll();
    }
  }

  // ✅ 7. معرفة الحالة
  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('prayer_notifications') ?? true;
  }
}
