import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../models/medicine_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Phnom_Penh'));

    // Android channel setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    await _createNotificationChannel();
    await _requestPermissions();
  }

  /// Request required Android permissions
  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      debugPrint("Notifications permission granted? $granted");

      final exact = await android.requestExactAlarmsPermission();
      debugPrint("Exact alarm permission granted? $exact");
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'med_channel_v2', // channel ID
      'Medicine Alerts', // channel name
      description: 'Reminders to take your medicine',
      importance: Importance.max,
      playSound: true,
    );

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(androidChannel);
      debugPrint("✅ Notification channel created");
    }
  }

  /// Schedule a notification
  Future<void> scheduleNotification(Medicine medicine) async {
    if (!medicine.isRemind) return;

    // Convert to local timezone
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(medicine.dateTime.toLocal(), tz.local);

    final now = tz.TZDateTime.now(tz.local);
    debugPrint("⏰ Now: $now | Scheduled: $scheduledDate");

    // Skip if scheduled time is in the past
    if (scheduledDate.isBefore(now)) {
      debugPrint("⚠️ Notification skipped: $scheduledDate is in the past");
      return;
    }

    // Schedule the notification
    await _notifications.zonedSchedule(
      medicine.id.hashCode, // unique id per medicine
      '💊 Pill Reminder',
      'Time to take ${medicine.amount} of ${medicine.name}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel_v2',
          'Medicine Alerts',
          channelDescription: 'Reminders to take your medicine',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // optional daily repeat
    );

    debugPrint("✅ Notification scheduled for $scheduledDate");
  }

  /// Cancel a notification by medicine ID
  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
    debugPrint("❌ Notification canceled for id: $id");
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint("❌ All notifications canceled");
  }
}
