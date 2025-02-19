import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>((event, emit) {
      final tasks = taskBox.values.toList();
      emit(TaskLoaded(tasks));
    });

    on<AddTask>((event, emit) {
      taskBox.add(event.task);
      emit(TaskLoaded(taskBox.values.toList()));
    });

    on<UpdateTask>((event, emit) {
      taskBox.putAt(event.index, event.task);
      emit(TaskLoaded(taskBox.values.toList()));
    });

    on<DeleteTask>((event, emit) {
      taskBox.deleteAt(event.index);
      emit(TaskLoaded(taskBox.values.toList()));
    });
  }
}
