import 'package:flutter/material.dart';
import 'package:classly/controller/kanban_controller.dart';
import 'package:classly/model/tarefa_model.dart';
import 'package:classly/widgets/barra_navegacao.dart';

const _verde = Color(0xFF00BFA5);
const _verdeEscuro = Color(0xFF00897B);
const _gradiente = LinearGradient(
  colors: [Color(0xFF00D4B4), Color(0xFF00917F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final KanbanController _controller = KanbanController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([Tarefa? tarefa]) => showDialog(
        context: context,
        builder: (_) =>
            _TarefaFormDialog(controller: _controller, tarefa: tarefa),
      );

  Future<void> _confirmarRemocao(Tarefa t) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover tarefa'),
        content: Text('Deseja remover "${t.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmou == true) _controller.remover(t.id);
  }

  /// Toque longo no card: mover de coluna, editar ou excluir.
  void _abrirAcoes(Tarefa t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(t.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            for (final s in StatusTarefa.values)
              if (s != t.status)
                ListTile(
                  leading:
                      const Icon(Icons.swap_horiz, color: _verdeEscuro),
                  title: Text('Mover para ${s.nome}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _controller.mover(t.id, s);
                  },
                ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _verdeEscuro),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirFormulario(t);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Excluir',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmarRemocao(t);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Botão + (nova tarefa)
      floatingActionButton: Container(
        decoration:
            const BoxDecoration(gradient: _gradiente, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _abrirFormulario(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
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
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B8A0).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                // ---- conteúdo do card ----
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quadro Kanban',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text('Organize suas tarefas por etapas',
                        style: TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 480,
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return Scrollbar(
                            controller: _scroll,
                            thumbVisibility: true,
                            child: ListView(
                              controller: _scroll,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 16),
                              children: [
                                for (final s in StatusTarefa.values)
                                  _ColunaKanban(
                                    status: s,
                                    tarefas: _controller.tarefasDoStatus(s),
                                    onTocar: _abrirFormulario,
                                    onSegurar: _abrirAcoes,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // Barra inferior reutilizável (aba 0 = Início, 1 = Kanban, 2 = Planejar, 3 = Aulas)
      bottomNavigationBar: const BarraNavegacao(currentIndex: 1),
    );
  }
}


// Coluna
class _ColunaKanban extends StatelessWidget {
  final StatusTarefa status;
  final List<Tarefa> tarefas;
  final void Function(Tarefa) onTocar;
  final void Function(Tarefa) onSegurar;

  const _ColunaKanban({
    required this.status,
    required this.tarefas,
    required this.onTocar,
    required this.onSegurar,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icone, List<Color> fundo, Color borda) = switch (status) {
      StatusTarefa.aFazer => (
          Icons.radio_button_unchecked,
          [const Color(0xFFF8FAFC), const Color(0xFFEFF3F5)],
          const Color(0xFFE2E8F0),
        ),
      StatusTarefa.emAndamento => (
          Icons.access_time,
          [const Color(0xFFF0FDFA), const Color(0xFFCCFBF1)],
          const Color(0xFFB2F5EA),
        ),
      StatusTarefa.concluido => (
          Icons.check_circle_outline,
          [const Color(0xFFCCFBF1), const Color(0xFF99F6E4)],
          const Color(0xFF5EEAD4),
        ),
    };

    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: fundo,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: const Color(0xFF0F766E), size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(status.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${tarefas.length}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: tarefas.isEmpty
                ? const Center(
                    child: Text('Nenhuma tarefa',
                        style: TextStyle(color: Color(0xFF94A3B8))))
                : ListView.separated(
                    itemCount: tarefas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CartaoTarefa(
                      tarefa: tarefas[i],
                      onTocar: () => onTocar(tarefas[i]),
                      onSegurar: () => onSegurar(tarefas[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card da tarefa
// ---------------------------------------------------------------------------
class _CartaoTarefa extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTocar;
  final VoidCallback onSegurar;

  const _CartaoTarefa({
    required this.tarefa,
    required this.onTocar,
    required this.onSegurar,
  });

  @override
  Widget build(BuildContext context) {
    const icones = {
      1: Icons.error_outline,
      2: Icons.remove,
      3: Icons.arrow_downward,
    };
    final corPrioridade =
        tarefa.prioridade == 1 ? const Color(0xFF0F172A) : _verdeEscuro;
    final dataHora = tarefa.dataHoraTexto;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF5EEAD4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTocar, // toque = editar
        onLongPress: onSegurar, // toque longo = mover / excluir
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(tarefa.titulo,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(icones[tarefa.prioridade],
                            size: 14, color: corPrioridade),
                        const SizedBox(width: 3),
                        Text('P${tarefa.prioridade}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: corPrioridade)),
                      ],
                    ),
                  ),
                ],
              ),
              if (tarefa.descricao.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(tarefa.descricao,
                    style: const TextStyle(
                        color: Color(0xFF475569), fontSize: 14)),
              ],
              if (tarefa.disciplina.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6FBF5),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(tarefa.disciplina,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00695C),
                          fontWeight: FontWeight.w600)),
                ),
              ],
              if (dataHora.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(dataHora,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário (Nova Tarefa / Editar Tarefa)
// ---------------------------------------------------------------------------
InputDecoration _decoracao(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _verde, width: 1.5)),
    );

Widget _rotulo(String t, {bool obrigatorio = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text.rich(TextSpan(
        text: t,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155)),
        children: [
          if (obrigatorio)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      )),
    );

class _TarefaFormDialog extends StatefulWidget {
  final KanbanController controller;
  final Tarefa? tarefa;
  const _TarefaFormDialog({required this.controller, this.tarefa});

  @override
  State<_TarefaFormDialog> createState() => _TarefaFormDialogState();
}

class _TarefaFormDialogState extends State<_TarefaFormDialog> {
  late final TextEditingController _titulo;
  late final TextEditingController _disciplina;
  late final TextEditingController _descricao;
  DateTime? _data;
  TimeOfDay? _hora;
  late int _prioridade;

  bool get _editando => widget.tarefa != null;
  bool get _podeSalvar => _titulo.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _titulo = TextEditingController(text: t?.titulo ?? '')
      ..addListener(() => setState(() {})); // habilita/desabilita o botão
    _disciplina = TextEditingController(text: t?.disciplina ?? '');
    _descricao = TextEditingController(text: t?.descricao ?? '');
    _data = t?.data;
    _hora = t?.hora;
    _prioridade = t?.prioridade ?? 2;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _disciplina.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _escolherHora() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) setState(() => _hora = t);
  }

  void _salvar() {
    if (!_podeSalvar) return;
    if (_editando) {
      final antiga = widget.tarefa!;
      widget.controller.editar(Tarefa(
        id: antiga.id,
        titulo: _titulo.text.trim(),
        disciplina: _disciplina.text.trim(),
        descricao: _descricao.text.trim(),
        data: _data,
        hora: _hora,
        prioridade: _prioridade,
        status: antiga.status,
      ));
    } else {
      widget.controller.adicionar(
        titulo: _titulo.text,
        disciplina: _disciplina.text,
        descricao: _descricao.text,
        data: _data,
        hora: _hora,
        prioridade: _prioridade,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(gradient: _gradiente),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_editando ? 'Editar Tarefa' : 'Nova Tarefa',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rotulo('Título', obrigatorio: true),
                  TextField(
                    controller: _titulo,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoracao('Ex: Estudar para prova de Matemática'),
                  ),
                  _rotulo('Disciplina'),
                  TextField(
                    controller: _disciplina,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoracao('Ex: Matemática'),
                  ),
                  _rotulo('Descrição'),
                  TextField(
                    controller: _descricao,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 4,
                    decoration: _decoracao('Adicione detalhes sobre a tarefa...'),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _rotulo('Data'),
                            _CampoSelecao(
                              texto: _data == null ? null : formatarDataBr(_data!),
                              hint: 'dd/mm/aaaa',
                              onTap: _escolherData,
                              onLimpar: () => setState(() => _data = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _rotulo('Hora'),
                            _CampoSelecao(
                              texto: _hora == null ? null : formatarHoraBr(_hora!),
                              hint: '--:--',
                              onTap: _escolherHora,
                              onLimpar: () => setState(() => _hora = null),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _rotulo('Prioridade'),
                  Row(
                    children: [
                      for (final p in const [3, 2, 1]) ...[
                        Expanded(
                          child: _TilePrioridade(
                            valor: p,
                            selecionado: _prioridade == p,
                            onTap: () => setState(() => _prioridade = p),
                          ),
                        ),
                        if (p != 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _podeSalvar ? _gradiente : null,
                        color: _podeSalvar ? null : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _podeSalvar ? _salvar : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _editando ? 'Salvar Alterações' : 'Criar Tarefa',
                          style: TextStyle(
                              color: _podeSalvar
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo que abre um seletor (data/hora) ao tocar.
class _CampoSelecao extends StatelessWidget {
  final String? texto;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onLimpar;

  const _CampoSelecao({
    required this.texto,
    required this.hint,
    required this.onTap,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: _decoracao(''),
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto ?? hint,
                style: TextStyle(
                    color: texto == null
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A)),
              ),
            ),
            if (texto != null)
              InkWell(
                onTap: onLimpar,
                child: const Icon(Icons.close,
                    size: 16, color: Color(0xFF94A3B8)),
              ),
          ],
        ),
      ),
    );
  }
}

class _TilePrioridade extends StatelessWidget {
  final int valor; // 1 alta, 2 média, 3 baixa
  final bool selecionado;
  final VoidCallback onTap;

  const _TilePrioridade({
    required this.valor,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (String nome, IconData icone) = switch (valor) {
      1 => ('Alta', Icons.error_outline),
      2 => ('Média', Icons.remove),
      _ => ('Baixa', Icons.arrow_downward),
    };
    final cores = valor == 1
        ? const [Color(0xFF00796B), Color(0xFF004D40)]
        : const [Color(0xFF00C9AD), Color(0xFF00897B)];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selecionado
              ? LinearGradient(
                  colors: cores,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          color: selecionado ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selecionado ? cores.last : Colors.transparent, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icone,
                size: 22,
                color: selecionado ? Colors.white : const Color(0xFF475569)),
            const SizedBox(height: 4),
            Text(nome,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selecionado ? Colors.white : const Color(0xFF475569))),
            Text('P$valor',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color:
                        selecionado ? Colors.white : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}