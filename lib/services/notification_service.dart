import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/deadline.dart';

/// Handles local notifications for deadline reminders.
/// Schedules notifications at 9:00 AM on the reminder date.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  bool get permissionGranted => _permissionGranted;
  bool get isInitialized => _initialized;

  /// Initialize the notification plugin and timezone data.
  /// Call once at app startup.
  Future<void> initialize() async {
    if (kIsWeb) {
      // Local notifications not supported on web
      _initialized = false;
      return;
    }

    // Initialize timezone
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }

    // Initialize plugin
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permission from the user.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    // Android 13+ requires explicit permission
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      // On Android < 13, this returns null – notifications are allowed by default
      _permissionGranted = granted ?? true;
    }

    // iOS
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _permissionGranted = granted ?? false;
    }

    // If neither platform-specific check ran, assume granted
    if (androidPlugin == null && iosPlugin == null) {
      _permissionGranted = true;
    }

    return _permissionGranted;
  }

  /// Schedule reminders for a deadline based on its reminder days.
  /// Notifications fire at 9:00 AM on the reminder date.
  Future<void> scheduleDeadlineReminders(Deadline deadline) async {
    if (!_initialized || !_permissionGranted) return;
    if (deadline.isCompleted || deadline.isArchived) return;

    for (final daysBefore in deadline.reminders) {
      final reminderDate = deadline.dueDate.subtract(
        Duration(days: daysBefore),
      );

      // Schedule at 9:00 AM
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
        0,
      );

      // Don't schedule in the past
      if (scheduledDate.isBefore(DateTime.now())) continue;

      final id = _notificationId(deadline.id, daysBefore);
      final title = deadline.title;
      final body = _buildBody(deadline, daysBefore);

      await _scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    }

    // Also schedule a notification on the due date itself
    final dueDateTime = DateTime(
      deadline.dueDate.year,
      deadline.dueDate.month,
      deadline.dueDate.day,
      9,
      0,
    );
    if (dueDateTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _notificationId(deadline.id, 0),
        title: deadline.title,
        body: '${deadline.type.label} ist heute fällig.',
        scheduledDate: dueDateTime,
      );
    }
  }

  /// Cancel all reminders for a specific deadline.
  Future<void> cancelAllRemindersForDeadline(Deadline deadline) async {
    if (!_initialized) return;

    for (final daysBefore in deadline.reminders) {
      await _plugin.cancel(_notificationId(deadline.id, daysBefore));
    }
    // Also cancel the due-date notification
    await _plugin.cancel(_notificationId(deadline.id, 0));
  }

  /// Cancel a single reminder.
  Future<void> cancelReminder(int notificationId) async {
    if (!_initialized) return;
    await _plugin.cancel(notificationId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  /// Get count of pending notifications (for debugging).
  Future<int> pendingCount() async {
    if (!_initialized) return 0;
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  /// Send a test notification immediately (for debugging).
  Future<void> sendTestNotification() async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Fristen-Erinnerungen',
      channelDescription: 'Erinnerungen an wichtige Fristen',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      99999,
      'FristFix Test',
      'Benachrichtigungen funktionieren!',
      details,
    );
  }

  // --- Private helpers ---

  int _notificationId(String deadlineId, int daysBefore) {
    return '${deadlineId}_$daysBefore'.hashCode.abs() % 2147483647;
  }

  String _buildBody(Deadline deadline, int daysBefore) {
    final typeLabel = deadline.type.label;

    if (daysBefore >= 90) {
      return '$typeLabel in 3 Monaten. Frühzeitig prüfen.';
    }
    if (daysBefore >= 60) {
      return '$typeLabel in 2 Monaten.';
    }
    if (daysBefore >= 30) {
      final months = daysBefore ~/ 30;
      return '$typeLabel in ${months == 1 ? "1 Monat" : "$months Monaten"}.';
    }
    if (daysBefore == 14) {
      return '$typeLabel in 2 Wochen.';
    }
    if (daysBefore == 7) {
      return 'Bitte prüfen: $typeLabel in 7 Tagen.';
    }
    if (daysBefore == 3) {
      return '$typeLabel in 3 Tagen. Bitte zeitnah prüfen.';
    }
    if (daysBefore == 1) {
      return '$typeLabel ist morgen fällig.';
    }
    return '$typeLabel in $daysBefore Tagen.';
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Fristen-Erinnerungen',
      channelDescription: 'Erinnerungen an wichtige Fristen',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to deadline details when notification is tapped
    // This would require a global navigation key or a callback
  }
}
