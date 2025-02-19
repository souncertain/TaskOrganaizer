import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final int? taskIndex;

  const AddTaskScreen({this.task, this.taskIndex, super.key});
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      final timeParts = widget.task!.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить задачу')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Заголовок')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Описание')),

            SizedBox(height: 16),
            ListTile(
              title: Text(_selectedTime == null
                  ? 'Выбрать время'
                  : 'Выбрано: ${_selectedTime!.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
            ),
            SizedBox(height: 16,),
            ListTile(
              title: Text(_selectedDate == null
              ? "Выбрать дату" 
              : ("Выбрано: ${_selectedDate!.toLocal().toString().split(' ')[0]}")
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async{
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(), 
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null){
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty || _selectedTime == null || _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите данные')));
                  return;
                }

                String formattedTime = _selectedTime!.format(context);

                DateTime taskDateTime = DateTime(
                  _selectedDate!.year, 
                  _selectedDate!.month, 
                  _selectedDate!.day, 
                  _selectedTime!.hour, 
                  _selectedTime!.minute
                );

                DateTime notificationTime30 = taskDateTime.subtract(Duration(minutes: 30));
                DateTime notificationTime5 = taskDateTime.subtract(Duration(minutes: 5));

                int notificationId30 = _generateNotificationId(notificationTime30, 30);
                int notificationId5 = _generateNotificationId(notificationTime5, 5);

                final updatedTask = Task(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  datetime: _selectedDate!,
                  time: formattedTime,
                  notificationId30: notificationId30,
                  notificationId5: notificationId5
                );

                if(widget.taskIndex != null){
                  if (widget.task!.notificationId30 != null) {
                    NotificationService().cancelNotification(widget.task!.notificationId30!);
                  }
                  if (widget.task!.notificationId5 != null) {
                    NotificationService().cancelNotification(widget.task!.notificationId5!);
                  }
                  context.read<TaskBloc>().add(UpdateTask(widget.taskIndex!, updatedTask));
                } else {
                  context.read<TaskBloc>().add(AddTask(updatedTask));
                }

                NotificationService().scheduleNotification(notificationId30, notificationTime30, _titleController.text);
                NotificationService().scheduleNotification(notificationId5, notificationTime5, _titleController.text);

                Navigator.pop(context);
              },
              child: Text(widget.task == null ? 'Сохранить' : 'Обновить'),
            ),
          ],
        ),
      ),
    );
  }

  int _generateNotificationId(DateTime dateTime, int offset) {
    String uniqueString = '${dateTime.year}-${dateTime.month}-${dateTime.day}-${dateTime.hour}-${dateTime.minute}-$offset';
    return uniqueString.hashCode.abs(); // Хэш от строки
  }
}
