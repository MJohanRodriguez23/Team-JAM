import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/screens/register_screen.dart';
import 'package:to_do_ufpso/services/auth_service.dart';

void main() {
  testWidgets('RegisterScreen valida campos vacios e invalidos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text('Crear Cuenta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Registrarse'), findsOneWidget);

    await tester.tap(find.text('Registrarse'));
    await tester.pump();

    expect(
      find.text('Por favor, ingrese su correo electrónico'),
      findsOneWidget,
    );
    expect(find.text('Por favor, ingrese una contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'correo_invalido');
    await tester.enterText(find.byType(TextFormField).last, '12345');
    await tester.tap(find.text('Registrarse'));
    await tester.pump();

    expect(find.text('Por favor, ingrese un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener mínimo 6 caracteres'),
      findsOneWidget,
    );
  });

  testWidgets(
    'RegisterScreen crea la cuenta y navega a home cuando Firebase responde ok',
    (WidgetTester tester) async {
      final fakeAuthService = _FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/register',
          routes: {
            '/register': (context) =>
                RegisterScreen(authService: fakeAuthService),
            '/home': (context) => const HomeScreen(),
          },
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'estudiante@ufpso.edu.co',
      );
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(fakeAuthService.lastEmail, 'estudiante@ufpso.edu.co');
      expect(fakeAuthService.lastPassword, '123456');
      expect(find.text('Mis Tareas'), findsOneWidget);
    },
  );

  testWidgets(
    'RegisterScreen muestra un mensaje entendible si Firebase devuelve error',
    (WidgetTester tester) async {
      final fakeAuthService = _FakeAuthService(
        error: const AuthFailure(
          'Ese correo ya esta registrado. Intenta iniciar sesion.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(authService: fakeAuthService)),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'estudiante@ufpso.edu.co',
      );
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.text('Registrarse'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Ese correo ya esta registrado. Intenta iniciar sesion.'),
        findsOneWidget,
      );
      expect(find.text('Crear Cuenta'), findsOneWidget);
    },
  );
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.error});

  final AuthFailure? error;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;

    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (error != null) {
      throw error!;
    }
  }
}
