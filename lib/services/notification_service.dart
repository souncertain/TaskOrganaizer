import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Europe/Moscow'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
                // other properties...
              ),
            ));
      }
    });
}

  Future<void> cancelNotification(int id) async {
      await flutterLocalNotificationsPlugin.cancel(id);
      log('Удалено уведомление: ${id}');
    }

  Future<void> scheduleNotification(int id, DateTime dateTime, String title) async {

    // Проверяем, что время уведомления находится в будущем
    if (dateTime.isBefore(DateTime.now())) {
      return; // Прекращаем выполнение, если время уже прошло
    }

      // Настройки для Android
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_channel',
      'Задачи',
      channelDescription: 'Напоминания о задачах',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public, // Видимость на заблокированном экране
      playSound: true, 
      enableVibration: true, 
    );
    final notificationDetails = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Планируем уведомление
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      'Напоминание о задаче',
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}