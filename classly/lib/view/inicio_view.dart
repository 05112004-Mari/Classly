import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/barra_navegacao.dart';
import 'task.dart';
import 'tarefas_view.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  List<Task> _items = [];
  List<Task> get _tasks => _items.where((t) => !t.isExam).toList();
  List<Task> get _exams => _items.where((t) => t.isExam).toList();

  /// Marca ou desmarca como concluído
  void _toggle(int id) {
    setState(() {
      _items = _items
          .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
          .toList();
    });
  }

  /// Salva edição
  void _update(Task updated) {
    setState(() {
      _items = _items.map((t) => t.id == updated.id ? updated : t).toList();
    });
  }

  // Adiciona item novo
  void _add(Task newTask) {
    setState(() {
      _items = [
        ..._items,
        Task(
          id: DateTime.now().millisecondsSinceEpoch,
          title: newTask.title,
          description: newTask.description,
          priority: newTask.priority,
          dueDate: newTask.dueDate,
          dueTime: newTask.dueTime,
          subject: newTask.subject,
          isExam: newTask.isExam,
        ),
      ];
    });
  }

  void _openCreateModal() {
    showTaskFormSheet(context, onSave: _add);
  }

  void _openEditModal(Task task) {
    showTaskFormSheet(context, initialData: task, onSave: _update);
  }

  /// Abre tarefas concluídas
  void _openCompletedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final completed = _tasks.where((t) => t.completed).toList();
            return _CompletedTasksSheet(
              tasks: completed,
              onToggle: (id) {
                _toggle(id);
                setModalState(() {});
              },
              onTaskClick: (task) {
                Navigator.of(sheetContext).pop();
                _openEditModal(task);
              },
            );
          },
        );
      },
    );
  }

  // Abre a tela tarefas pendentes
  void _openPendingTasksScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TarefasView(
          getTasks: () => _tasks,
          onToggle: _toggle,
          onUpdate: _update,
        ),
      ),
    );
  }

  // calculo progresso
  ({int total, int completed, double studiedHours}) get _stats {
    final tasks = _tasks;
    final completedCount = tasks.where((t) => t.completed).length;
    return (
      total: tasks.length,
      completed: completedCount,
      studiedHours: completedCount * 0.75,
    );
  }

  // data
  String get _currentDate {
    final text = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now());
    return text[0].toUpperCase() + text.substring(1);
  }

  // hora
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    // Só as 4 primeiras tarefas pendentes aparecem
    final pendingTasks = _tasks.where((t) => !t.completed).take(4).toList();
    final exams = _exams;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // Botão fadicionar
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateModal,
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      // Barra de navegação inferior
      bottomNavigationBar: const BarraNavegacao(currentIndex: 0),

      // cabeçalho
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_greeting!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentDate,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Perfil
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB2DFDB)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B8A0).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF00B8A0),
                    ),
                    tooltip: 'Perfil',
                    onPressed: () {
                      Navigator.pushNamed(context, 'perfil');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cards de resumo
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_box_outlined,
                    value: '${stats.total}',
                    label: 'Tarefas',
                    onTap: _openPendingTasksScreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '${stats.completed}',
                    label: 'Concluídas',
                    onTap: _openCompletedModal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tarefas
            DashboardCard(
              title: 'Tarefas de Hoje',
              icon: Icons.check_box_outlined,
              emptyMessage: 'Nenhuma tarefa pendente. Toque em + para adicionar.',
              children: [
                for (final task in pendingTasks)
                  TaskCard(
                    task: task,
                    onTap: () => _openEditModal(task),
                    onToggle: () => _toggle(task.id),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Provas
            DashboardCard(
              title: 'Próximas Provas',
              icon: Icons.menu_book_outlined,
              emptyMessage: 'Nenhuma prova cadastrada. Toque em + e escolha "Prova".',
              children: [
                for (final exam in exams)
                  TaskCard(
                    task: exam,
                    onTap: () => _openEditModal(exam),
                    onToggle: () => _toggle(exam.id),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Progresso semanal, calculo
            ProgressoSemanal(
              completedTasks: stats.completed,
              totalTasks: stats.total,
              studiedHours: stats.studiedHours,
              weeklyGoalHours: 7,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Card de resumo
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.teal.shade600),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// título e ícone
class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? emptyMessage;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (children.isEmpty && emptyMessage != null)
            Text(
              emptyMessage!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          else
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              children[i],
            ],
        ],
      ),
    );
  }
}

// Item de tarefa/prova
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case Priority.high:
        return const Color.fromARGB(255, 1, 59, 51);
      case Priority.medium:
        return const Color(0xFF00B8A0);
      case Priority.low:
        return const Color.fromARGB(255, 28, 255, 225);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
          border: Border(left: BorderSide(color: _priorityColor, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) => onToggle(),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                  if (task.dueDate.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.dueTime != null
                          ? '${task.dueDate} às ${task.dueTime}'
                          : task.dueDate,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Barra de progresso
class ProgressoSemanal extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final double studiedHours;
  final double weeklyGoalHours;

  const ProgressoSemanal({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.studiedHours,
    required this.weeklyGoalHours,
  });

  @override
  Widget build(BuildContext context) {
    if (totalTasks == 0) {
      return DashboardCard(
        title: 'Progresso Semanal',
        icon: Icons.trending_up,
        children: const [],
        emptyMessage: 'Adicione tarefas e conclua-as para acompanhar seu progresso.',
      );
    }

    final progress = weeklyGoalHours == 0
        ? 0.0
        : (studiedHours / weeklyGoalHours).clamp(0.0, 1.0);

    return DashboardCard(
      title: 'Progresso Semanal',
      icon: Icons.trending_up,
      children: [
        Text(
          '$completedTasks de $totalTasks tarefas concluídas',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: Colors.teal.shade600,
            backgroundColor: Colors.teal.shade100,
          ),
        ),
        Text(
          '${studiedHours.toStringAsFixed(1)}h / ${weeklyGoalHours.toStringAsFixed(0)}h estudadas',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// tarefas concluidas

class _CompletedTasksSheet extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int id) onToggle;
  final void Function(Task task) onTaskClick;

  const _CompletedTasksSheet({
    required this.tasks,
    required this.onToggle,
    required this.onTaskClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarefas Concluídas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nenhuma tarefa concluída ainda.')),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => TaskCard(
                  task: tasks[i],
                  onTap: () => onTaskClick(tasks[i]),
                  onToggle: () => onToggle(tasks[i].id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//criar ou editar

void showTaskFormSheet(
  BuildContext context, {
  Task? initialData,
  required void Function(Task task) onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskFormSheet(initialData: initialData, onSave: onSave),
  );
}

class _TaskFormSheet extends StatefulWidget {
  final Task? initialData;
  final void Function(Task task) onSave;

  const _TaskFormSheet({this.initialData, required this.onSave});

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _subject;
  late final TextEditingController _dueDate;
  late final TextEditingController _dueTime;
  late Priority _priority;
  late bool _isExam;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initialData;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _subject = TextEditingController(text: t?.subject ?? '');
    _dueDate = TextEditingController(text: t?.dueDate ?? '');
    _dueTime = TextEditingController(text: t?.dueTime ?? '');
    _priority = t?.priority ?? Priority.medium;
    _isExam = t?.isExam ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subject.dispose();
    _dueDate.dispose();
    _dueTime.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dueDate.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      _dueTime.text = picked.format(context);
    }
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;

    final base = widget.initialData;
    final task = Task(
      id: base?.id ?? 0,
      title: _title.text.trim(),
      description: _description.text.trim(),
      priority: _priority,
      dueDate: _dueDate.text.trim(),
      dueTime: _dueTime.text.trim().isEmpty ? null : _dueTime.text.trim(),
      subject: _subject.text.trim(),
      completed: base?.completed ?? false,
      isExam: _isExam,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final label = _isExam ? 'Prova' : 'Tarefa';

    return Padding(
      // viewInsets.bottom = altura do teclado; empurra o formulário para cima.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Editar $label' : 'Nova $label',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (!_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tarefa')),
                      ButtonSegment(value: true, label: Text('Prova')),
                    ],
                    selected: {_isExam},
                    onSelectionChanged: (s) => setState(() => _isExam = s.first),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Matéria'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: const [
                  DropdownMenuItem(value: Priority.low, child: Text('Baixa')),
                  DropdownMenuItem(value: Priority.medium, child: Text('Média')),
                  DropdownMenuItem(value: Priority.high, child: Text('Alta')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? _priority),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dueDate,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _dueTime,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Hora (opcional)',
                        suffixIcon: Icon(Icons.access_time, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isEditing ? 'Salvar alterações' : 'Criar ${label.toLowerCase()}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}