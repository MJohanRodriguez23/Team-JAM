import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/services/firestore_task_repository.dart';
import 'package:to_do_ufpso/services/firebase_bootstrap.dart';
import 'package:to_do_ufpso/services/task_repository.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, TaskRepository? taskRepository})
    : taskRepository = taskRepository ?? const _DefaultTaskRepository();

  final TaskRepository taskRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _DefaultTaskRepository implements TaskRepository {
  const _DefaultTaskRepository();

  @override
  Stream<TaskSyncSnapshot> watchTasks() {
    return FirestoreTaskRepository().watchTasks();
  }

  @override
  Future<Task> createTask(String title) {
    return FirestoreTaskRepository().createTask(title);
  }

  @override
  Future<List<Task>> loadTasks() {
    return FirestoreTaskRepository().loadTasks();
  }

  @override
  Future<Task> updateTask(Task task) {
    return FirestoreTaskRepository().updateTask(task);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  bool _isLoading = true;
  StreamSubscription<TaskSyncSnapshot>? _taskSubscription;
  bool _hadPendingWrites = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    await _taskSubscription?.cancel();
    _taskSubscription = widget.taskRepository.watchTasks().listen(
      _handleSyncSnapshot,
      onError: (error) {
        if (!mounted) {
          return;
        }

        final message = error is TaskFailure
            ? error.message
            : 'No se pudieron sincronizar tus tareas. Intenta nuevamente.';
        _showMessage(message);

        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  void _handleSyncSnapshot(TaskSyncSnapshot snapshot) {
    if (!mounted) {
      return;
    }

    setState(() {
      _tasks
        ..clear()
        ..addAll(snapshot.tasks);
      _isLoading = false;
    });

    if (!_hadPendingWrites && snapshot.hasPendingWrites) {
      _showMessage(
        'Cambios guardados localmente. Se sincronizaran cuando vuelva la conexion.',
      );
    }

    if (_hadPendingWrites && !snapshot.hasPendingWrites) {
      _showMessage('Cambios sincronizados con Firestore.');
    }

    _hadPendingWrites = snapshot.hasPendingWrites;
  }

  Future<void> _showCreateTaskDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        String taskTitle = '';
        bool isSubmitting = false;

        Future<void> submitTask(
          void Function(void Function()) setDialogState,
        ) async {
          final trimmedTitle = taskTitle.trim();

          if (trimmedTitle.isEmpty) {
            setDialogState(() {
              errorText = 'Ingresa un titulo para crear la tarea';
            });
            return;
          }

          setDialogState(() {
            errorText = null;
            isSubmitting = true;
          });

          try {
            await widget.taskRepository.createTask(trimmedTitle);

            Navigator.of(dialogContext).pop();
          } on TaskFailure catch (error) {
            if (!mounted) {
              return;
            }

            setDialogState(() {
              isSubmitting = false;
            });

            _showMessage(error.message);
          }
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear tarea'),
              content: TextFormField(
                key: const Key('task_title_field'),
                autofocus: true,
                enabled: !isSubmitting,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Titulo de la tarea',
                  hintText: 'Ej. Estudiar para calculo',
                  errorText: errorText,
                ),
                onChanged: (value) {
                  taskTitle = value;
                  if (errorText != null) {
                    setDialogState(() {
                      errorText = null;
                    });
                  }
                },
                onFieldSubmitted: (_) => submitTask(setDialogState),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => submitTask(setDialogState),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    try {
      await widget.taskRepository.updateTask(updatedTask);
    } on TaskFailure catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);

    navigator.pushReplacementNamed('/login');

    try {
      await FirebaseBootstrap.ensureInitialized();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Aun no tienes tareas guardadas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea tu primera tarea para guardarla en tu cuenta y encontrarla luego.',
                        style: TextStyle(color: AppColors.gray),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _showCreateTaskDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Crear mi primera tarea'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tus tareas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tus tareas se cargan desde Firestore para esta cuenta.',
                      style: TextStyle(color: AppColors.gray),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = _tasks[index];

                          return Card(
                            child: ListTile(
                              onTap: () => _toggleTaskStatus(task),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Icon(
                                task.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task.isCompleted
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color: task.isCompleted
                                      ? AppColors.gray
                                      : AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                task.isCompleted
                                    ? 'Tarea completada'
                                    : 'Tarea pendiente',
                              ),
                              trailing: IconButton(
                                key: Key('toggle_task_${task.id}'),
                                onPressed: () => _toggleTaskStatus(task),
                                icon: Icon(
                                  task.isCompleted ? Icons.undo : Icons.check,
                                ),
                                tooltip: task.isCompleted
                                    ? 'Marcar como pendiente'
                                    : 'Marcar como completada',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
