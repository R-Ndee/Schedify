import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/event_model.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  // ✅ Helper to log (developer console). Removed in-app debug capture.
  void _log(String message, {String name = 'NotificationService'}) {
    developer.log(message, name: name);
  }

  // ✅ Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
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
      const androidChannel = AndroidNotificationChannel(
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
    } catch (e, st) {
      developer.log('⚠️ Error initializing notification service: $e', name: 'NotificationService');
      developer.log('Stack trace: $st', name: 'NotificationService');
      // Mark as initialized anyway so we can continue; notifications just won't work
      _isInitialized = true;
    }
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
    if (!_isInitialized) {
      _log('⚠️ Notification service not initialized, skipping schedule');
      return;
    }
    
    _log('📌 scheduleEventNotification called for: ${event.title}');
    _log('   hasReminder: ${event.hasReminder}, reminderMinutes: ${event.reminderMinutes}');
    _log('   startTime: ${event.startTime}');
    _log('   now: ${DateTime.now()}');
    
    if (!event.hasReminder || event.reminderMinutes == 0) {
      _log('⚠️ Event ${event.title} has no reminder or reminderMinutes=0');
      return;
    }

    // Check permission
    if (!await hasPermission()) {
      _log('⚠️ Notification permission not granted');
      return;
    }

    // Calculate notification time
    final notificationTime = event.startTime.subtract(
      Duration(minutes: event.reminderMinutes),
    );

    _log('   calculatedNotificationTime: $notificationTime');
    _log('   time remaining: ${notificationTime.difference(DateTime.now()).inSeconds} seconds');

    // Don't schedule if time already passed
    if (notificationTime.isBefore(DateTime.now())) {
      _log('⚠️ Notification time already passed for ${event.title}');
      _log('   notificationTime: $notificationTime, now: ${DateTime.now()}');
      return;
    }

    // Create notification
    try {
      await _scheduleNotification(
        id: event.id.hashCode,
        title: '🔔 Upcoming Event',
        body: '${event.title} will start in ${event.reminderMinutes} minutes',
        scheduledDate: notificationTime,
        payload: event.id,
      );

      _log('✅ Scheduled notification for ${event.title}');
      _log('   ID: ${event.id.hashCode}');
      _log('   Scheduled for: $notificationTime');
    } catch (e, st) {
      _log('❌ Failed to schedule notification: $e');
      _log('Stack trace: $st');
      // Don't rethrow - let database operation continue
    }
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
    
    _log('🔧 _scheduleNotification internal call');
    _log('   ID: $id');
    _log('   Title: $title');
    _log('   Body: $body');
    _log('   Scheduled TZ: $scheduledTZ');
    _log('   Timezone location: ${tz.local}');

    _log('   Calling zonedSchedule...');
    
    try {
      // Use a minimal, non-const NotificationDetails to avoid serialization
      // / type-parameter issues in some plugin/platform versions.
      final androidDetails = AndroidNotificationDetails(
        'event_reminders',
        'Event Reminders',
        channelDescription: 'Notifications for upcoming events',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(android: androidDetails, iOS: darwinDetails);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      _log('✅ zonedSchedule API call succeeded');
    } catch (e) {
      _log('❌ zonedSchedule threw exception: $e');
      rethrow;
    }
  }

  // ✅ Cancel notification for event
  Future<void> cancelEventNotification(String eventId) async {
    if (!_isInitialized) {
      developer.log('⚠️ Notification service not initialized yet, skipping cancel', name: 'NotificationService');
      return;
    }
    final notificationId = eventId.hashCode;
    try {
      await _notifications.cancel(notificationId);
      developer.log('✅ Cancelled notification for event: $eventId', name: 'NotificationService');
    } catch (e, st) {
      developer.log('⚠️ Failed to cancel notification for $eventId: $e', name: 'NotificationService');
      developer.log('$st', name: 'NotificationService');
      // Don't rethrow: cancellation failure should not block DB operations
    }
  }

  // ✅ Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      developer.log('⚠️ Notification service not initialized yet, skipping cancelAllNotifications', name: 'NotificationService');
      return;
    }
    try {
      await _notifications.cancelAll();
      developer.log('✅ Cancelled all notifications', name: 'NotificationService');
    } catch (e, st) {
      developer.log('⚠️ Failed to cancel all notifications: $e', name: 'NotificationService');
      developer.log('$st', name: 'NotificationService');
    }
  }

  // ✅ Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      developer.log('⚠️ Notification service not initialized, skipping immediate notification', name: 'NotificationService');
      return;
    }
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        const NotificationDetails(
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
      developer.log('✅ Immediate notification sent', name: 'NotificationService');
    } catch (e, st) {
      developer.log('⚠️ Failed to show immediate notification: $e', name: 'NotificationService');
      developer.log('$st', name: 'NotificationService');
    }
  }

  // ✅ Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      developer.log('⚠️ Notification service not initialized yet', name: 'NotificationService');
      return <PendingNotificationRequest>[];
    }
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e, st) {
      developer.log('⚠️ Failed to get pending notifications: $e', name: 'NotificationService');
      developer.log('$st', name: 'NotificationService');
      return <PendingNotificationRequest>[];
    }
  }
}
