import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/medicine_model.dart';
// import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  // final StorageService _storage = StorageService();

  // Global settings
  bool _enableNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;
  // TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);

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
    debugPrint('✅ NotificationService initialized');
  }

  void applyGlobalSettings({
    required bool enableNotifications,
    required bool sound,
    required bool vibration,
    required double volume,
    required TimeOfDay dailyReminderTime,
  }) {
    _enableNotifications = enableNotifications;
    _soundEnabled = sound;
    _vibrationEnabled = vibration;
    _volume = volume;
    // _dailyReminderTime = dailyReminderTime;

    debugPrint(
  '⚙️ Settings applied: Notifications=$_enableNotifications, Sound=$_soundEnabled, Vibration=$_vibrationEnabled, Volume=$_volume, DailyReminder=${dailyReminderTime.hour.toString().padLeft(2,'0')}:${dailyReminderTime.minute.toString().padLeft(2,'0')}'
);
  }

  Future<void> scheduleNotification(Medicine medicine) async {
    if (!_enableNotifications || !medicine.isRemind) return;

    final scheduledDate = tz.TZDateTime.from(medicine.dateTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'med_channel_v2',
      'Medicine Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: _soundEnabled,
      enableVibration: _vibrationEnabled,
      vibrationPattern: _vibrationEnabled ? Int64List.fromList([0, 500, 1000, 500]) : null,
      sound: _soundEnabled ? RawResourceAndroidNotificationSound('notification') : null,
    );

    await _notifications.zonedSchedule(
      medicine.id.hashCode & 0x7fffffff,
      '💊 Time to take ${medicine.name}',
      'Take ${medicine.amount} of ${medicine.name}',
      scheduledDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('⏰ Scheduled: ${medicine.name} at $scheduledDate');
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode & 0x7fffffff);
  }

  Future<void> cancelAllNotifications() async => await _notifications.cancelAll();
}
