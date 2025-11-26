import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  // ✅ Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    try {
      // Best-effort attempt to set the tz package local location.
      // We avoid flutter_native_timezone here because some plugin versions
      // require Android Gradle Plugin namespace changes which can fail
      // on certain setups. As a fallback we try to map DateTime's
      // timeZoneName to a tz location if possible.
      final localName = DateTime.now().timeZoneName;
      if (tz.timeZoneDatabase.locations.containsKey(localName)) {
        tz.setLocalLocation(tz.getLocation(localName));
      } else {
        developer.log('Local timezone "$localName" not found in tz database; using default tz.local', name: 'NotificationService');
      }
    } catch (e) {
      developer.log('Failed to set local timezone, using default tz.local: $e', name: 'NotificationService');
    }
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel (required on Android 8.0+)
    final androidChannel = const AndroidNotificationChannel(
      'event_reminders',
      'Event Reminders',
      description: 'Notifications for upcoming events',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
    developer.log('✅ Notification service initialized', name: 'NotificationService');
  }

  // ✅ Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}', name: 'NotificationService');
    // TODO: Navigate to event detail
  }

  // ✅ Request permission (Android 13+)
  Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ✅ Check if has permission
  Future<bool> hasPermission() async {
    return await Permission.notification.isGranted;
  }

  // ✅ Schedule notification for event
  Future<void> scheduleEventNotification(EventModel event) async {
    if (!event.hasReminder || event.reminderMinutes == 0) {
      developer.log('⚠️ Event ${event.title} has no reminder', name: 'NotificationService');
      return;
    }

    // Check permission
    if (!await hasPermission()) {
      developer.log('⚠️ Notification permission not granted', name: 'NotificationService');
      return;
    }

    // Calculate notification time
    final notificationTime = event.startTime.subtract(
      Duration(minutes: event.reminderMinutes),
    );

    // Don't schedule if time already passed
    if (notificationTime.isBefore(DateTime.now())) {
      developer.log('⚠️ Notification time already passed for ${event.title}', name: 'NotificationService');
      return;
    }

    // Create notification
    await _scheduleNotification(
      id: event.id.hashCode,
      title: '🔔 Upcoming Event',
      body: '${event.title} will start in ${event.reminderMinutes} minutes',
      scheduledDate: notificationTime,
      payload: event.id,
    );

    developer.log('✅ Scheduled notification for ${event.title} at $notificationTime', name: 'NotificationService');
  }

  // ✅ Schedule notification at specific time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for upcoming events',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF2196F3),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ✅ Cancel notification for event
  Future<void> cancelEventNotification(String eventId) async {
    final notificationId = eventId.hashCode;
    await _notifications.cancel(notificationId);
    developer.log('✅ Cancelled notification for event: $eventId', name: 'NotificationService');
  }

  // ✅ Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    developer.log('✅ Cancelled all notifications', name: 'NotificationService');
  }

  // ✅ Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for upcoming events',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ✅ Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}