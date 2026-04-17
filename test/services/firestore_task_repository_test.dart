import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_ufpso/services/firestore_task_repository.dart';

void main() {
  group('FirestoreTaskRepository', () {
    test(
      'loadTasks consulta y devuelve solo las tareas asociadas al usuario autenticado',
      () async {
        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('users')
            .doc('user-a')
            .collection('tasks')
            .doc('task-1')
            .set({
              'title': 'Tarea de user-a',
              'description': '',
              'isCompleted': false,
              'createdAt': DateTime(2026, 4, 17),
            });

        await firestore
            .collection('users')
            .doc('user-b')
            .collection('tasks')
            .doc('task-2')
            .set({
              'title': 'Tarea de user-b',
              'description': '',
              'isCompleted': false,
              'createdAt': DateTime(2026, 4, 18),
            });

        final repository = FirestoreTaskRepository(
          firestore: firestore,
          currentUserId: 'user-a',
          ensureInitialized: () async {},
        );

        final tasks = await repository.loadTasks();

        expect(tasks, hasLength(1));
        expect(tasks.first.title, 'Tarea de user-a');
      },
    );

    test(
      'loadTasks retorna lista vacia cuando el usuario no tiene tareas guardadas',
      () async {
        final firestore = FakeFirebaseFirestore();

        final repository = FirestoreTaskRepository(
          firestore: firestore,
          currentUserId: 'user-sin-tareas',
          ensureInitialized: () async {},
        );

        final tasks = await repository.loadTasks();

        expect(tasks, isEmpty);
      },
    );
  });
}
