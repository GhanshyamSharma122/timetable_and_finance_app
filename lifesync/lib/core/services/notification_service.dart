import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    // based on response.payload
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (_plugin == null) return;

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Reminders for scheduled tasks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin!.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> scheduleBudgetAlert({
    required int id,
    required String category,
    required double percentage,
  }) async {
    if (_plugin == null) return;

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Alerts when budget limits are reached',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin!.show(
      id,
      'Budget Alert: $category',
      'You have used ${percentage.toStringAsFixed(0)}% of your $category budget',
      notificationDetails,
    );
  }

  static Future<void> scheduleLendingReminder({
    required int id,
    required String personName,
    required double amount,
    required DateTime dueDate,
    required bool isOwed,
  }) async {
    if (_plugin == null) return;

    const androidDetails = AndroidNotificationDetails(
      'lending_reminders',
      'Lending Reminders',
      channelDescription: 'Reminders for money lending/borrowing due dates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final title = isOwed 
        ? 'Payment Due: $personName owes you' 
        : 'Payment Due: You owe $personName';
    final body = '₹${amount.toStringAsFixed(2)} is due today';

    await _plugin!.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dueDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin?.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin?.cancelAll();
  }
}
