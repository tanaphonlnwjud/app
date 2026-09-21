import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/deadline_record.model.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleFor(DeadlineRecord record) async {
    await cancelFor(record.notificationId);
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'homework_deadlines',
        'กำหนดส่งงาน',
        channelDescription: 'การแจ้งเตือนกำหนดส่งงานล่วงหน้า',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    for (final daysBefore in [2, 1]) {
      final reminder = record.deadline.subtract(Duration(days: daysBefore));
      if (!reminder.isAfter(DateTime.now())) continue;
      await _plugin.zonedSchedule(
        record.notificationId + daysBefore,
        'ใกล้ถึงกำหนดส่งงาน',
        '${record.title} เหลือเวลาอีก $daysBefore วัน',
        tz.TZDateTime.from(reminder, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: record.id,
      );
    }
  }

  Future<void> showTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'homework_deadlines',
        'กำหนดส่งงาน',
        channelDescription: 'การแจ้งเตือนกำหนดส่งงานล่วงหน้า',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      999999,
      'ทดสอบการแจ้งเตือน',
      'ระบบแจ้งเตือนของ Nisit Hub ใช้งานได้แล้ว',
      details,
    );
  }

  Future<void> cancelFor(int notificationId) async {
    await _plugin.cancel(notificationId + 1);
    await _plugin.cancel(notificationId + 2);
  }
}