import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/services/task_repository.dart';

void main() {
  testWidgets(
    'HomeScreen muestra estado vacio y opcion de crear cuando no hay tareas guardadas',
    (WidgetTester tester) async {
      final repository = _FakeTaskRepository();

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aun no tienes tareas guardadas'), findsOneWidget);
      expect(
        find.text(
          'Crea tu primera tarea para guardarla en tu cuenta y encontrarla luego.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.text('Crear mi primera tarea'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets('HomeScreen guarda una tarea y la muestra en la lista', (
    WidgetTester tester,
  ) async {
    final repository = _FakeTaskRepository();

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(taskRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear'));
    await tester.pump();

    expect(find.text('Ingresa un titulo para crear la tarea'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('task_title_field')),
      'Estudiar arquitectura de software',
    );
    await tester.tap(find.text('Crear'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Tus tareas'), findsOneWidget);
    expect(find.text('Estudiar arquitectura de software'), findsOneWidget);
    expect(find.text('Tarea pendiente'), findsOneWidget);
    expect(
      repository.savedTitles,
      contains('Estudiar arquitectura de software'),
    );
  });

  testWidgets(
    'HomeScreen recarga tareas persistidas al volver a abrir la app',
    (WidgetTester tester) async {
      final repository = _FakeTaskRepository(
        initialTasks: [Task(id: '1', title: 'Entrega de proyecto')],
      );

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrega de proyecto'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrega de proyecto'), findsOneWidget);
      expect(find.text('Tus tareas'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen muestra un mensaje entendible si ocurre un error al guardar',
    (WidgetTester tester) async {
      final repository = _FakeTaskRepository(
        createError: const TaskFailure(
          'No se pudo guardar la tarea. Intenta nuevamente.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task_title_field')),
        'Preparar exposicion',
      );
      await tester.tap(find.text('Crear'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo guardar la tarea. Intenta nuevamente.'),
        findsOneWidget,
      );
      expect(find.text('Aun no tienes tareas guardadas'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen permite marcar una tarea persistida como completada y volverla a pendiente',
    (WidgetTester tester) async {
      final repository = _FakeTaskRepository(
        initialTasks: [
          Task(id: '1', title: 'Resolver taller de bases de datos'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resolver taller de bases de datos'), findsOneWidget);
      expect(find.text('Tarea pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.byTooltip('Marcar como completada'));
      await tester.pumpAndSettle();

      expect(find.text('Tarea completada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.byTooltip('Marcar como pendiente'));
      await tester.pumpAndSettle();

      expect(find.text('Tarea pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen informa cuando hay cambios pendientes y cuando se sincronizan al reconectar',
    (WidgetTester tester) async {
      final repository = _FakeTaskRepository();

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(taskRepository: repository)),
      );
      await tester.pumpAndSettle();

      await repository.emitSyncState(
        TaskSyncSnapshot(
          tasks: [Task(id: '1', title: 'Tarea offline')],
          hasPendingWrites: true,
          isFromCache: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Cambios guardados localmente. Se sincronizaran cuando vuelva la conexion.',
        ),
        findsOneWidget,
      );

      await repository.emitSyncState(
        TaskSyncSnapshot(
          tasks: [Task(id: '1', title: 'Tarea offline')],
          hasPendingWrites: false,
          isFromCache: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cambios sincronizados con Firestore.'), findsOneWidget);
    },
  );
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({List<Task>? initialTasks, this.createError})
    : _tasks = List<Task>.from(initialTasks ?? []) {
    _controller = StreamController<TaskSyncSnapshot>.broadcast(
      onListen: () {
        _controller.add(TaskSyncSnapshot(tasks: _snapshotTasks()));
      },
    );
  }

  final List<Task> _tasks;
  final TaskFailure? createError;
  final List<String> savedTitles = [];
  late final StreamController<TaskSyncSnapshot> _controller;

  List<Task> _snapshotTasks() => _tasks.map((task) => task.copyWith()).toList();

  Future<void> emitSyncState(TaskSyncSnapshot snapshot) async {
    _controller.add(snapshot);
  }

  @override
  Stream<TaskSyncSnapshot> watchTasks() => _controller.stream;

  @override
  Future<Task> createTask(String title) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (createError != null) {
      throw createError!;
    }

    savedTitles.add(title);
    final task = Task(id: (_tasks.length + 1).toString(), title: title);
    _tasks.insert(0, task);
    _controller.add(
      TaskSyncSnapshot(
        tasks: _snapshotTasks(),
        hasPendingWrites: false,
        isFromCache: false,
      ),
    );
    return task;
  }

  @override
  Future<List<Task>> loadTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _snapshotTasks();
  }

  @override
  Future<Task> updateTask(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith();
    }
    _controller.add(
      TaskSyncSnapshot(
        tasks: _snapshotTasks(),
        hasPendingWrites: false,
        isFromCache: false,
      ),
    );
    return task;
  }
}
