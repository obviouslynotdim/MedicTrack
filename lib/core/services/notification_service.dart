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

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Phnom_Penh'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
      ),
    );

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    debugPrint('✅ NotificationService initialized + permissions granted');
  }

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
    debugPrint(
      '⚙️ Notification settings applied: '
      'enable=$_enableNotifications, sound=$_soundEnabled, vibration=$_vibrationEnabled, volume=$_volume',
    );
  }

  Future<void> scheduleNotification(
    Medicine medicine, {
    bool dailyRepeat = false,
    TimeOfDay? reminderTime,
  }) async {
    if (!_enableNotifications || !medicine.isRemind) return;

    final now = tz.TZDateTime.now(tz.local);

    // Use either the medicine's dateTime or the daily reminder time
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
      // If the time today has already passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } else {
      scheduledDate = tz.TZDateTime.from(medicine.dateTime, tz.local);
      if (scheduledDate.isBefore(now)) {
        // show immediately if already passed
        await _notifications.show(
          medicine.id.hashCode & 0x7fffffff,
          '💊 Time to take ${medicine.name}',
          'Take ${medicine.amount} of ${medicine.name}',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'med_channel_v2',
              'Medicine Alerts',
              importance: Importance.max,
              priority: Priority.high,
              playSound: _soundEnabled,
              enableVibration: _vibrationEnabled,
              vibrationPattern: _vibrationEnabled
                  ? Int64List.fromList([0, 500, 1000, 500])
                  : null,
              sound: _soundEnabled
                  ? RawResourceAndroidNotificationSound('notification')
                  : null,
            ),
          ),
        );
        return;
      }
    }

    // Schedule notification
    await _notifications.zonedSchedule(
      medicine.id.hashCode & 0x7fffffff,
      '💊 Time to take ${medicine.name}',
      'Take ${medicine.amount} of ${medicine.name}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel_v2',
          'Medicine Alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: _soundEnabled,
          enableVibration: _vibrationEnabled,
          vibrationPattern: _vibrationEnabled
              ? Int64List.fromList([0, 500, 1000, 500])
              : null,
          sound: _soundEnabled
              ? RawResourceAndroidNotificationSound('notification')
              : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dailyRepeat ? DateTimeComponents.time : null,
    );

    debugPrint(
      '⏰ Scheduled notification for ${medicine.name} at $scheduledDate',
    );
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode & 0x7fffffff);
  }

  Future<void> cancelAllNotifications() async =>
      await _notifications.cancelAll();
}
