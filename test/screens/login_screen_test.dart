import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/screens/login_screen.dart';
import 'package:to_do_ufpso/services/auth_service.dart';
import 'package:to_do_ufpso/services/task_repository.dart';

void main() {
  testWidgets('LoginScreen valida campos vacios e invalidos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Iniciar Sesion'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.bySemanticsLabel('Google'), findsOneWidget);
    expect(find.bySemanticsLabel('GitHub'), findsOneWidget);
    expect(find.bySemanticsLabel('Facebook'), findsOneWidget);
    expect(find.text('¿No tienes una cuenta? '), findsOneWidget);
    expect(find.text('Registrate gratis'), findsOneWidget);

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(
      find.text('Por favor, ingrese su correo electrónico'),
      findsOneWidget,
    );
    expect(find.text('Por favor, ingrese una contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'correo_invalido');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Por favor, ingrese un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener mínimo 6 caracteres'),
      findsOneWidget,
    );
  });

  testWidgets(
    'LoginScreen inicia sesion y navega a home con credenciales validas',
    (WidgetTester tester) async {
      final fakeAuthService = _FakeAuthService();
      final fakeTaskRepository = _FakeTaskRepository();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(authService: fakeAuthService),
            '/home': (context) =>
                HomeScreen(taskRepository: fakeTaskRepository),
          },
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'estudiante@ufpso.edu.co',
      );
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(fakeAuthService.lastEmail, 'estudiante@ufpso.edu.co');
      expect(fakeAuthService.lastPassword, '123456');
      expect(find.text('Mis Tareas'), findsOneWidget);
      expect(find.text('Aun no tienes tareas guardadas'), findsOneWidget);
    },
  );

  testWidgets(
    'LoginScreen muestra un mensaje entendible si las credenciales son incorrectas',
    (WidgetTester tester) async {
      final fakeAuthService = _FakeAuthService(
        error: const AuthFailure(
          'Las credenciales ingresadas no son correctas.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authService: fakeAuthService)),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'estudiante@ufpso.edu.co',
      );
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Las credenciales ingresadas no son correctas.'),
        findsOneWidget,
      );
      expect(find.text('Iniciar Sesion'), findsOneWidget);
    },
  );
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.error});

  final AuthFailure? error;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> login({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;

    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (error != null) {
      throw error!;
    }
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
