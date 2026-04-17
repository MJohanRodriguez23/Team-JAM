import 'package:to_do_ufpso/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadTasks();

  Future<Task> createTask(String title);

  Future<Task> updateTask(Task task);
}

class TaskFailure implements Exception {
  const TaskFailure(this.message);

  final String message;
}
