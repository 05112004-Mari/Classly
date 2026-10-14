import 'package:flutter/material.dart';
import 'task.dart';
import 'inicio_view.dart';

class TarefasView extends StatefulWidget {
  final List<Task> Function() getTasks;
  final void Function(int id) onToggle;
  final void Function(Task task) onUpdate;

  const TarefasView({
    super.key,
    required this.getTasks,
    required this.onToggle,
    required this.onUpdate,
  });

  @override
  State<TarefasView> createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefasView> {
  List<Task> get _pending {
    final list = widget.getTasks().where((t) => !t.completed).toList();
    list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return list;
  }

  // Conclui a tarefa
  void _toggle(int id) {
    widget.onToggle(id);
    setState(() {});
  }

  // atualizar
  void _edit(Task task) {
    showTaskFormSheet(
      context,
      initialData: task,
      onSave: (updated) {
        widget.onUpdate(updated);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tarefas Pendentes'),
        backgroundColor: const Color.fromARGB(255, 41, 205, 183),
        foregroundColor: Colors.white,
      ),
      body: pending.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.teal.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Tudo em dia!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você não tem tarefas pendentes.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  pending.length == 1
                      ? '1 tarefa pendente'
                      : '${pending.length} tarefas pendentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                for (final task in pending) ...[
                  TaskCard(
                    task: task,
                    onTap: () => _edit(task),
                    onToggle: () => _toggle(task.id),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}