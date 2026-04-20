import 'package:to_do_ufpso/models/task.dart';

abstract class TaskRepository {
  Stream<TaskSyncSnapshot> watchTasks();

  Future<List<Task>> loadTasks();

  Future<Task> createTask(String title);

  Future<Task> updateTask(Task task);
}

class TaskFailure implements Exception {
  const TaskFailure(this.message);

  final String message;
}

class TaskSyncSnapshot {
  const TaskSyncSnapshot({
    required this.tasks,
    this.hasPendingWrites = false,
    this.isFromCache = false,
  });

  final List<Task> tasks;
  final bool hasPendingWrites;
  final bool isFromCache;
}
