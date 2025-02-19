import 'package:flutter/material.dart';
import '../models/task.dart';

@immutable
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final int index;
  final Task task;
  UpdateTask(this.index, this.task);
}

class DeleteTask extends TaskEvent {
  final int index;
  DeleteTask(this.index);
}
