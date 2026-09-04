import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, defaultTargetPlatform, TargetPlatform;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:workmanager/workmanager.dart';

import '../models/deadline.dart';
import '../models/reminder.dart';
import '../data/hive_deadline_adapter.dart';
import 'recurrence_service.dart';

/// Unique task name for the periodic background notification refresh.
const String backgroundTaskName = 'de.fristfix.refreshNotifications';

/// Called by WorkManager in the background (runs in an isolate).
/// This is a top-level function (required by workmanager).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == backgroundTaskName || taskName == Workmanager.iOSBackgroundTask) {
        await _refreshRecurringNotifications();
      }
    } catch (e) {
      debugPrint('Background task failed: $e');
    }
    return true;
  });
}

/// Core logic: reads deadlines from Hive, advances recurring ones,
/// and reschedules notifications. Runs without Flutter UI context.
Future<void> _refreshRecurringNotifications() async {
  // Initialize Hive
  await Hive.initFlutter();
  final box = await HiveDeadlineAdapter.openBox();

  // Initialize timezone
  tz_data.initializeTimeZones();
  try {
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  }

  // Initialize notifications plugin
  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await plugin.initialize(settings);

  final recurrenceService = const RecurrenceService();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Process all deadlines
  for (final key in box.keys) {
    try {
      final jsonStr = box.get(key as String);
      if (jsonStr == null) continue;

      final deadline = HiveDeadlineAdapter.fromHiveValue(jsonStr);

      if (!deadline.isRecurring || deadline.isCompleted || deadline.isArchived) {
        continue;
      }

      final dueDay = DateTime(
        deadline.dueDate.year,
        deadline.dueDate.month,
        deadline.dueDate.day,
      );

      if (dueDay.isBefore(today)) {
        // Advance to next future occurrence
        final nextDueDate =
            recurrenceService.calculateNextFutureOccurrence(deadline);
        final updated = deadline.copyWith(
          dueDate: nextDueDate,
          isCompleted: false,
          updatedAt: DateTime.now(),
        );

        // Save updated deadline
        await box.put(key, HiveDeadlineAdapter.toHiveValue(updated));

        // Schedule notifications for the updated deadline
        await _scheduleNotificationsForDeadline(plugin, updated, recurrenceService);
      } else {
        // Due date is in the future – ensure notifications are scheduled
        await _scheduleNotificationsForDeadline(plugin, deadline, recurrenceService);
      }
    } catch (e) {
      debugPrint('Background: error processing deadline $key: $e');
    }
  }
}

/// Schedule notifications for a single deadline (background-safe).
Future<void> _scheduleNotificationsForDeadline(
  FlutterLocalNotificationsPlugin plugin,
  Deadline deadline,
  RecurrenceService recurrenceService,
) async {
  final reminderDates = recurrenceService.calculateReminderDates(deadline);
  final effectiveReminders = deadline.effectiveReminders;

  for (int i = 0; i < reminderDates.length; i++) {
    final scheduledDate = reminderDates[i];
    if (scheduledDate.isBefore(DateTime.now())) continue;

    final id = _notificationId(deadline.id, i);
    final body = _buildBody(deadline, effectiveReminders[i]);

    await _schedule(plugin, id, deadline.title, body, scheduledDate);
  }

  // Due-date notification at 9:00 AM
  final effectiveDueDate =
      recurrenceService.calculateNextFutureOccurrence(deadline);
  final dueDateTime = DateTime(
    effectiveDueDate.year,
    effectiveDueDate.month,
    effectiveDueDate.day,
    9,
    0,
  );
  if (dueDateTime.isAfter(DateTime.now())) {
    final typeLabel = deadline.type.label;
    final body = deadline.isRecurring
        ? '$typeLabel ist heute fällig. (${deadline.recurrenceLabel})'
        : '$typeLabel ist heute fällig.';
    await _schedule(
        plugin, _notificationId(deadline.id, 999), deadline.title, body, dueDateTime);
  }
}

Future<void> _schedule(
  FlutterLocalNotificationsPlugin plugin,
  int id,
  String title,
  String body,
  DateTime scheduledDate,
) async {
  final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

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

  await plugin.zonedSchedule(
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

int _notificationId(String deadlineId, int index) {
  return '${deadlineId}_idx_$index'.hashCode.abs() % 2147483647;
}

String _buildBody(Deadline deadline, Reminder reminder) {
  final typeLabel = deadline.type.label;
  final label = reminder.label;
  if (deadline.isRecurring) {
    return '$typeLabel: $label (${deadline.recurrenceLabel})';
  }
  return '$typeLabel: $label';
}

/// Service class to initialize and register the background task.
/// Call [initialize] once from main.dart.
class BackgroundService {
  /// Initialize WorkManager and register the periodic task.
  /// Should be called after WidgetsFlutterBinding.ensureInitialized().
  static Future<void> initialize() async {
    if (kIsWeb) return;

    // iOS BGTaskScheduler requires native handler registration inside
    // didFinishLaunchingWithOptions, which Dart code cannot satisfy in time.
    // Skip on iOS to avoid the "No launch handler registered" crash.
    if (defaultTargetPlatform == TargetPlatform.iOS) return;

    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Register a periodic task that runs approximately every 12 hours.
    // Android minimum interval is 15 minutes, but we use 12 hours to
    // be battery-friendly while still catching recurring deadlines.
    await Workmanager().registerPeriodicTask(
      backgroundTaskName,
      backgroundTaskName,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}
