import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sfedu_project/firebase_options.dart';
import 'services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'task_organaizer_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const TaskOrganaizerApp());
}
