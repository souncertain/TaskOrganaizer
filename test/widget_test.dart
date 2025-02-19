import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sfedu_project/bloc/task_bloc.dart';
import 'package:sfedu_project/bloc/task_state.dart';
import 'package:sfedu_project/models/task.dart';
import 'package:sfedu_project/screens/task_list_screen.dart';
import 'package:hive/hive.dart';

class MockTaskBloc extends Mock implements TaskBloc {
  @override
  Stream<TaskState> get stream => Stream<TaskState>.empty();
}

void main() {
  late MockTaskBloc mockTaskBloc;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('test_hive');
  });

  setUp(() {
    mockTaskBloc = MockTaskBloc();
  });

  testWidgets('Проверка рендеринга списка задач', (WidgetTester tester) async {
    final testTasks = [
      Task(title: 'Task 1', description: 'Desc 1', datetime: DateTime.now(), time: '10:00'),
      Task(title: 'Task 2', description: 'Desc 2', datetime: DateTime.now(), time: '12:00'),
    ];

    when(() => mockTaskBloc.state).thenReturn(TaskLoaded(testTasks));
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: mockTaskBloc,
          child: const TaskListScreen(),
        ),
      ),
    );

    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);
  });
}