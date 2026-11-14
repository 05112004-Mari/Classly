import 'package:classly/controller/tarefas_controller.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import 'inicio_view.dart';

class TarefasView extends StatefulWidget {
  const TarefasView({super.key});

  @override
  State<TarefasView> createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefasView> {
  static const Color _teal = Color(0xFF00B8A0);
  static const Color _borda = Color(0xFFB2DFDB);
  static const Color _textoEscuro = Color(0xFF0F172A);

  final TarefasController _controller = TarefasController();
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

  // Conclui a tarefa
  Future<void> _toggle(Task task) async {
    try {
      await _controller.alternarConclusao(task);
    } catch (_) {
      if (!mounted) return;
      _mensagem('Não foi possível atualizar a tarefa.', erro: true);
    }
  }

  // Atualizar
  void _edit(Task task) {
    showTaskFormSheet(
      context,
      initialData: task,
      onSave: (updated) async {
        await _controller.editar(updated);
        if (!mounted) return;
        _mensagem('Tarefa atualizada com sucesso!');
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

  // Falha ao ler o Firestore
  Widget _erro() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível carregar as suas tarefas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                setState(() => _stream = _controller.tarefasDoUsuario()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
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
            onToggle: () => _toggle(task),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _conteudo(AsyncSnapshot<List<Task>> snapshot) {
    if (snapshot.hasError) return _erro();

    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: _teal)),
      );
    }

    final pending = TarefasController.pendentes(snapshot.data ?? const []);
    return pending.isEmpty ? _vazio() : _lista(pending);
  }

  @override
  Widget build(BuildContext context) {
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
                    // StreamBuilder: atualiza sozinho quando o Firestore muda
                    StreamBuilder<List<Task>>(
                      stream: _stream,
                      builder: (context, snapshot) => _conteudo(snapshot),
                    ),
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