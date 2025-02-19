import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime datetime;

  @HiveField(3)
  String time;

  @HiveField(4) 
  int? notificationId30; 

  @HiveField(5) 
  int? notificationId5;

  Task({
    required this.title,
    required this.description,
    required this.datetime,
    required this.time,
    this.notificationId30,
    this.notificationId5,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? datetime,
    String? time,
    int? notificationId30,
    int? notificationId5,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      datetime: datetime ?? this.datetime,
      time: time ?? this.time,
      notificationId30: notificationId30 ?? this.notificationId30,
      notificationId5: notificationId5 ?? this.notificationId5,
    );
  }
}
