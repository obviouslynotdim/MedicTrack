import 'dart:io'; // Required for Platform check
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/medicine_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _enableNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;

  // Change this ID to force Android to create a fresh channel with updated settings
  static const String _channelId = 'med_alerts_v3'; 

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Phnom_Penh'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
      ),
    );

    await _notifications.initialize(settings);

    // Explicitly request permissions for Android 13+
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // 1. Request standard notification permission (Pop-up)
      await androidPlugin?.requestNotificationsPermission();

      // 2. Request/Check Exact Alarm permission (Android 14+)
      final bool? canScheduleExact = await androidPlugin?.canScheduleExactNotifications();
      if (canScheduleExact == false) {
        // This will redirect the user to the system settings page
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }

    debugPrint('✅ NotificationService initialized');
  }

  // Helper to build consistent notification details
  NotificationDetails _getNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Medicine Alerts',
        channelDescription: 'Notifications for scheduled medications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true, // Helps bypass some background restrictions
        playSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
        vibrationPattern: _vibrationEnabled
            ? Int64List.fromList([0, 500, 1000, 500])
            : null,
        sound: _soundEnabled
            ? const RawResourceAndroidNotificationSound('notification')
            : null,
      ),
    );
  }

  Future<void> scheduleNotification(
    Medicine medicine, {
    bool dailyRepeat = false,
    TimeOfDay? reminderTime,
  }) async {
    if (!_enableNotifications || !medicine.isRemind) return;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate;

    if (reminderTime != null) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } else {
      scheduledDate = tz.TZDateTime.from(medicine.dateTime, tz.local);
      
      // Fix: If time is in the past, don't just "show," schedule for 5 seconds from now
      // to ensure the system handles it correctly as a background task.
      if (scheduledDate.isBefore(now)) {
        scheduledDate = now.add(const Duration(seconds: 5));
      }
    }

    try {
      await _notifications.zonedSchedule(
        medicine.id.hashCode & 0x7fffffff,
        '💊 Time to take ${medicine.name}',
        'Take ${medicine.amount} of ${medicine.name}',
        scheduledDate,
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Crucial for battery saving
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: dailyRepeat ? DateTimeComponents.time : null,
      );
      debugPrint('⏰ Scheduled for ${medicine.name} at $scheduledDate');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }

  // Rest of your class methods (applyGlobalSettings, cancelNotification, etc.)
  void applyGlobalSettings({
    required bool enableNotifications,
    required bool sound,
    required bool vibration,
    required double volume,
    TimeOfDay? dailyReminderTime,
  }) {
    _enableNotifications = enableNotifications;
    _soundEnabled = sound;
    _vibrationEnabled = vibration;
    _volume = volume;
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode & 0x7fffffff);
  }

  Future<void> cancelAllNotifications() async => await _notifications.cancelAll();
}