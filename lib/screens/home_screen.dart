import 'package:flutter/material.dart';
import 'package:to_do_ufpso/models/task.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];

  Future<void> _showCreateTaskDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        String taskTitle = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear tarea'),
              content: TextFormField(
                key: const Key('task_title_field'),
                autofocus: true,
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
                onFieldSubmitted: (_) => _createTask(
                  dialogContext: dialogContext,
                  title: taskTitle,
                  setDialogState: setDialogState,
                  setErrorText: (value) => errorText = value,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => _createTask(
                    dialogContext: dialogContext,
                    title: taskTitle,
                    setDialogState: setDialogState,
                    setErrorText: (value) => errorText = value,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createTask({
    required BuildContext dialogContext,
    required String title,
    required void Function(void Function()) setDialogState,
    required void Function(String?) setErrorText,
  }) {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      setDialogState(() {
        setErrorText('Ingresa un titulo para crear la tarea');
      });
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: trimmedTitle,
        ),
      );
    });

    Navigator.of(dialogContext).pop();
  }

  void _toggleTaskStatus(Task task) {
    setState(() {
      task.toggleCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _tasks.isEmpty
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
                        'Aun no tienes tareas locales',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea tu primera tarea para empezar a organizar tus actividades.',
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
                      'Tus tareas locales',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crea tareas rapidas para organizar tus actividades.',
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
