import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfedu_project/models/task.dart';
import 'package:sfedu_project/services/notification_service.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade100,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildTaskList(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Новая задача', 
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500
          )),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTaskScreen()),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, 
              size: 120, 
              color: Colors.blue.shade100
            ),
            const SizedBox(height: 24),
            Text('Список задач пуст',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 16),
            Text('Нажмите кнопку ниже, чтобы добавить\nсвою первую задачу',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_task),
              label: const Text('Добавить задачу',
                style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, 
                  vertical: 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen()
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return Dismissible(
          key: Key(task.hashCode.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 32),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Удалить задачу?'),
                content: const Text('Вы уверены, что хотите удалить эту задачу?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Отмена')),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Удалить',
                      style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            if (task.notificationId30 != null) {
              NotificationService().cancelNotification(task.notificationId30!);
            }
            if (task.notificationId5 != null) {
              NotificationService().cancelNotification(task.notificationId5!);
            }
            context.read<TaskBloc>().add(DeleteTask(index));
          },
          child: _buildTaskCard(task, context, index),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                task: task,
                taskIndex: index,
              )
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(task.time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}