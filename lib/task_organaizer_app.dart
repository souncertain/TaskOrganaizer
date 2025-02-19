import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/task_list_screen.dart';
import 'package:flutter/material.dart';


class TaskOrganaizerApp extends StatelessWidget {
  const TaskOrganaizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Органайзер задач',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: TaskListScreen(),
      ),
    );
  }
}
