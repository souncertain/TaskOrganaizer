import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sfedu_project/task_organaizer_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sfedu_project/models/task.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';


class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return 'test/hive_testing';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  
    PathProviderPlatform.instance = FakePathProvider();

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    await Hive.openBox<Task>('tasks');
  });

  testWidgets('Добавление новой задачи', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskOrganaizerApp());

    expect(find.text('Мои задачи'), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Новая задача');
    
    await tester.enterText(find.byType(TextField).last, 'Описание задачи');

    await tester.tap(find.text('Выбрать время'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Выбрать дату'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Новая задача'), findsOneWidget);
  });
}
