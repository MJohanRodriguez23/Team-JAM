import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/screens/login_screen.dart';
import 'package:to_do_ufpso/screens/register_screen.dart';
import 'package:to_do_ufpso/services/auth_service.dart';
import 'package:to_do_ufpso/services/task_repository.dart';

void main() {
  testWidgets('HU-03 permite navegar entre login, registro y home', (
    WidgetTester tester,
  ) async {
    final fakeAuthService = _FakeAuthService();
    final fakeTaskRepository = _FakeTaskRepository();

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(authService: fakeAuthService),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => HomeScreen(taskRepository: fakeTaskRepository),
        },
      ),
    );

    expect(find.text('Iniciar Sesion'), findsOneWidget);

    await tester.tap(find.text('Registrate gratis'));
    await tester.pumpAndSettle();

    expect(find.text('Crear Cuenta'), findsOneWidget);
    expect(find.text('Ya tienes cuenta? Inicia sesion'), findsOneWidget);

    await tester.tap(find.text('Ya tienes cuenta? Inicia sesion'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar Sesion'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@ufpso.edu.co',
    );
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Mis Tareas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar Sesion'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  @override
  Future<void> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}
}

class _FakeTaskRepository implements TaskRepository {
  @override
  Stream<TaskSyncSnapshot> watchTasks() =>
      Stream.value(const TaskSyncSnapshot(tasks: []));

  @override
  Future<Task> createTask(String title) async => Task(id: '1', title: title);

  @override
  Future<List<Task>> loadTasks() async => [];

  @override
  Future<Task> updateTask(Task task) async => task;
}
