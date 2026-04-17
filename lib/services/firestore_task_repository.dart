import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/services/firebase_bootstrap.dart';
import 'package:to_do_ufpso/services/task_repository.dart';

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    String? currentUserId,
    Future<void> Function()? ensureInitialized,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth,
       _currentUserId = currentUserId,
       _ensureInitialized = ensureInitialized;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _firebaseAuth;
  final String? _currentUserId;
  final Future<void> Function()? _ensureInitialized;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Task> createTask(String title) async {
    await _ensureReady();

    try {
      final taskRef = _tasksCollection.doc();
      final task = Task(id: taskRef.id, title: title);

      await taskRef.set({
        ...task.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return task;
    } on FirebaseException {
      throw const TaskFailure(
        'No se pudo guardar la tarea. Intenta nuevamente.',
      );
    } catch (_) {
      throw const TaskFailure(
        'Ocurrio un error inesperado al guardar la tarea.',
      );
    }
  }

  @override
  Future<List<Task>> loadTasks() async {
    await _ensureReady();

    try {
      final snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException {
      throw const TaskFailure(
        'No se pudieron cargar tus tareas. Intenta nuevamente.',
      );
    } catch (_) {
      throw const TaskFailure(
        'Ocurrio un error inesperado al cargar las tareas.',
      );
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    await _ensureReady();

    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
      return task;
    } on FirebaseException {
      throw const TaskFailure(
        'No se pudo actualizar la tarea. Intenta nuevamente.',
      );
    } catch (_) {
      throw const TaskFailure(
        'Ocurrio un error inesperado al actualizar la tarea.',
      );
    }
  }

  Future<void> _ensureReady() async {
    try {
      await (_ensureInitialized ?? FirebaseBootstrap.ensureInitialized)();
    } on UnsupportedError {
      throw const TaskFailure(
        'Firestore no esta configurado para esta plataforma.',
      );
    } catch (_) {
      throw const TaskFailure(
        'Firebase no esta configurado todavia. Revisa la guia en docs/11_persistencia_tareas.md.',
      );
    }

    if (_resolvedUserId == null) {
      throw const TaskFailure(
        'Debes iniciar sesion para guardar y consultar tus tareas.',
      );
    }
  }

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final userId = _resolvedUserId!;
    return _db.collection('users').doc(userId).collection('tasks');
  }

  String? get _resolvedUserId => _currentUserId ?? _auth.currentUser?.uid;
}
