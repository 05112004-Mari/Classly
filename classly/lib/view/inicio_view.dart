import 'package:classly/controller/tarefas_controller.dart';
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
  static const Color _teal = Color(0xFF00B8A0);

  final TarefasController _controller = TarefasController();

  // Stream com as tarefas e provas do usuário (tempo real)
  late Stream<List<Task>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _controller.tarefasDoUsuario();
  }

  void _mensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.red.shade700 : _teal,
        behavior: SnackBarBehavior.floating,
      ));
  }

  /// Marca ou desmarca como concluído
  Future<void> _toggle(Task task) async {
    try {
      await _controller.alternarConclusao(task);
    } catch (_) {
      if (!mounted) return;
      _mensagem('Não foi possível atualizar o item.', erro: true);
    }
  }

  /// Cria (id vazio) ou edita (id preenchido). Lança exceção se falhar;
  /// o formulário mostra o erro.
  Future<void> _salvar(Task task) async {
    final editando = task.id.isNotEmpty;
    if (editando) {
      await _controller.editar(task);
    } else {
      await _controller.adicionar(task);
    }
    if (!mounted) return;
    final nome = task.isExam ? 'Prova' : 'Tarefa';
    _mensagem(editando
        ? '$nome atualizada com sucesso!'
        : '$nome criada com sucesso!');
  }

  void _openCreateModal() {
    showTaskFormSheet(context, onSave: _salvar);
  }

  void _openEditModal(Task task) {
    showTaskFormSheet(context, initialData: task, onSave: _salvar);
  }

  /// Abre tarefas concluídas
  void _openCompletedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StreamBuilder<List<Task>>(
          stream: _stream,
          builder: (context, snapshot) {
            final completed =
                TarefasController.concluidas(snapshot.data ?? const []);
            return _CompletedTasksSheet(
              tasks: completed,
              onToggle: _toggle,
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
      MaterialPageRoute(builder: (_) => const TarefasView()),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // Botão fadicionar
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateModal,
        backgroundColor: Color.fromARGB(255, 0, 137, 123),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      // Barra de navegação inferior
      bottomNavigationBar: const BarraNavegacao(currentIndex: 0),

      // cabeçalho
      body: SafeArea(
        // StreamBuilder: redesenha a tela sempre que o Firestore muda
        child: StreamBuilder<List<Task>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _TelaErro(
                onTentarNovamente: () =>
                    setState(() => _stream = _controller.tarefasDoUsuario()),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _teal),
              );
            }

            final items = snapshot.data ?? const <Task>[];
            final stats = TarefasController.resumo(items);
            // Só as 4 primeiras tarefas pendentes aparecem
            final pendingTasks =
                TarefasController.pendentes(items).take(4).toList();
            final exams = TarefasController.provas(items);

            return ListView(
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
                    onToggle: () => _toggle(task),
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
                    onToggle: () => _toggle(exam),
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
            );
          },
        ),
      ),
    );
  }
}

// Tela mostrada quando a leitura do Firestore falha
class _TelaErro extends StatelessWidget {
  final VoidCallback onTentarNovamente;
  const _TelaErro({required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            const Text('Não foi possível carregar os seus dados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTentarNovamente,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B8A0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
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
  final void Function(Task task) onToggle;
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
                  onToggle: () => onToggle(tasks[i]),
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
  required Future<void> Function(Task task) onSave,
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
  final Future<void> Function(Task task) onSave;

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
  bool _salvando = false;
  String? _erroTitulo;
  String? _erroSalvar;

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

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _erroTitulo = 'Informe o título');
      return;
    }

    final base = widget.initialData;
    final task = Task(
      id: base?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      priority: _priority,
      dueDate: _dueDate.text.trim(),
      dueTime: _dueTime.text.trim().isEmpty ? null : _dueTime.text.trim(),
      subject: _subject.text.trim(),
      completed: base?.completed ?? false,
      isExam: _isExam,
    );

    final navigator = Navigator.of(context);
    setState(() {
      _salvando = true;
      _erroTitulo = null;
      _erroSalvar = null;
    });

    try {
      await widget.onSave(task);
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erroSalvar = 'Não foi possível salvar. Tente novamente.';
      });
    }
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
                decoration:
                    InputDecoration(labelText: 'Título', errorText: _erroTitulo),
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
              if (_erroSalvar != null) ...[
                Text(_erroSalvar!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(_isEditing
                          ? 'Salvar alterações'
                          : 'Criar ${label.toLowerCase()}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}