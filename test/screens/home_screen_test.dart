import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';

void main() {
  testWidgets(
    'HomeScreen muestra un estado vacio y mantiene visible la opcion de crear tarea',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Aun no tienes tareas locales'), findsOneWidget);
      expect(
        find.text(
          'Crea tu primera tarea para empezar a organizar tus actividades.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.text('Crear mi primera tarea'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen crea una tarea local y valida que el titulo no este vacio',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Aun no tienes tareas locales'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Crear tarea'), findsOneWidget);

      await tester.tap(find.text('Crear'));
      await tester.pump();

      expect(
        find.text('Ingresa un titulo para crear la tarea'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('task_title_field')),
        'Estudiar arquitectura de software',
      );
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Tus tareas locales'), findsOneWidget);
      expect(find.text('Estudiar arquitectura de software'), findsOneWidget);
      expect(find.text('Tarea pendiente'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen permite marcar una tarea como completada y volverla a pendiente',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task_title_field')),
        'Resolver taller de bases de datos',
      );
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Resolver taller de bases de datos'), findsOneWidget);
      expect(find.text('Tarea pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.byTooltip('Marcar como completada'));
      await tester.pumpAndSettle();

      expect(find.text('Tarea completada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byTooltip('Marcar como pendiente'), findsOneWidget);

      final completedTitle = tester.widget<Text>(
        find.text('Resolver taller de bases de datos'),
      );
      expect(completedTitle.style?.decoration, TextDecoration.lineThrough);

      await tester.tap(find.byTooltip('Marcar como pendiente'));
      await tester.pumpAndSettle();

      expect(find.text('Tarea pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(find.byTooltip('Marcar como completada'), findsOneWidget);

      final pendingTitle = tester.widget<Text>(
        find.text('Resolver taller de bases de datos'),
      );
      expect(pendingTitle.style?.decoration, TextDecoration.none);
    },
  );
}
