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
  static const Color _teal = Color(0xFF00B8A0);
  static const Color _borda = Color(0xFFB2DFDB);
  static const Color _textoEscuro = Color(0xFF0F172A);

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

  Widget _cabecalho() {
    final voltar = Navigator.canPop(context);

    return Row(
      children: [
        if (voltar)
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28, color: _textoEscuro),
            onPressed: () => Navigator.pop(context),
          )
        else
          const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Tarefas Pendentes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textoEscuro,
            ),
          ),
        ),
      ],
    );
  }

  Widget _vazio() {
  return SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.teal.shade300),
          const SizedBox(height: 16),
          const Text(
            'Tudo em dia!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textoEscuro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você não tem tarefas pendentes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}

  Widget _lista(List<Task> pending) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDFA), Color(0xFFC8F1E8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 350,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _borda),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cabecalho(),
                    const SizedBox(height: 16),
                    if (pending.isEmpty) _vazio() else _lista(pending),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}