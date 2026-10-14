import 'package:flutter/material.dart';
import 'package:classly/controller/planejamento_controller.dart';
import 'package:classly/model/meta_model.dart';
import 'package:classly/model/plano_estudo_model.dart';
import 'package:classly/widgets/barra_navegacao.dart';

const _verde = Color(0xFF00BFA5);
const _verdeEscuro = Color(0xFF00897B);
const _gradiente = LinearGradient(
  colors: [Color(0xFF00D4B4), Color(0xFF00917F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Cores por prioridade
const _coresPrioridade = {
  1: (Color(0xFF00796B), Colors.white),
  2: (Color(0xFF00D4B4), Colors.white),
  3: (Color(0xFFB2F5EA), Color(0xFF00695C)),
};

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

Widget _rotulo(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(t,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155))),
    );

String? _obrigatorio(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

Future<bool> _confirmar(BuildContext context, String titulo, String texto) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
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
  return r == true;
}


// Tela
class PlanejarView extends StatefulWidget {
  const PlanejarView({super.key});

  @override
  State<PlanejarView> createState() => _PlanejarViewState();
}

class _PlanejarViewState extends State<PlanejarView> {
  final PlanejamentoController _controller = PlanejamentoController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirPlano([PlanoEstudo? plano]) => showDialog(
        context: context,
        builder: (_) => _PlanoFormDialog(controller: _controller, plano: plano),
      );

  Future<void> _abrirMeta([Meta? meta]) => showDialog(
        context: context,
        builder: (_) => _MetaFormDialog(controller: _controller, meta: meta),
      );

  Future<void> _removerPlano(PlanoEstudo p) async {
    if (await _confirmar(context, 'Remover plano',
        'Deseja remover o plano de "${p.disciplina}"?')) {
      _controller.removerPlano(p.id);
    }
  }

  Future<void> _removerMeta(Meta m) async {
    if (await _confirmar(
        context, 'Remover meta', 'Deseja remover "${m.titulo}"?')) {
      _controller.removerMeta(m.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BarraNavegacao(currentIndex: 2),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                const Text('Planejamento',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Organize seus estudos e metas',
                    style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 20),

                // Calendário
                _CartaoSecao(
                  icone: Icons.calendar_today_outlined,
                  titulo: 'Calendário',
                  child: _Calendario(prioridades: _controller.prioridadePorData),
                ),

                // Plano de estudos
                _CartaoSecao(
                  icone: Icons.track_changes,
                  titulo: 'Plano de Estudos Semanal',
                  child: Column(
                    children: [
                      for (final p in _controller.planos)
                        _CartaoPlano(
                          plano: p,
                          onEditar: () => _abrirPlano(p),
                          onRemover: () => _removerPlano(p),
                        ),
                      _BotaoTracejado(
                          texto: 'Adicionar Plano de Estudo',
                          onTap: () => _abrirPlano()),
                    ],
                  ),
                ),

                const _Legenda(),

                // Metas
                _CartaoSecao(
                  icone: Icons.track_changes,
                  titulo: 'Metas da Semana',
                  child: Column(
                    children: [
                      for (final m in _controller.metas)
                        _CartaoMeta(
                          meta: m,
                          onEditar: () => _abrirMeta(m),
                          onRemover: () => _removerMeta(m),
                          onAlternar: () =>
                              _controller.alternarConclusaoMeta(m.id),
                        ),
                      _BotaoTracejado(
                          texto: 'Adicionar Meta', onTap: () => _abrirMeta()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


// Cartão de seção (Calendário / Plano / Metas)
class _CartaoSecao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Widget child;
  const _CartaoSecao(
      {required this.icone, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icone, color: _verdeEscuro, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(titulo,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// Calendário
class _Calendario extends StatefulWidget {
  final Map<DateTime, int> prioridades;
  const _Calendario({required this.prioridades});

  @override
  State<_Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<_Calendario> {
  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  static const _semana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  late DateTime _mes;

  @override
  void initState() {
    super.initState();
    final h = DateTime.now();
    _mes = DateTime(h.year, h.month);
  }

  void _mudarMes(int delta) =>
      setState(() => _mes = DateTime(_mes.year, _mes.month + delta));

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final diasNoMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    final offset = DateTime(_mes.year, _mes.month, 1).weekday % 7; // dom = 0

    final celulas = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= diasNoMes; d++)
        _CelulaDia(
          dia: d,
          ehHoje: DateTime(_mes.year, _mes.month, d) == hoje,
          prioridade: widget.prioridades[DateTime(_mes.year, _mes.month, d)],
        ),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () => _mudarMes(-1),
                icon: const Icon(Icons.chevron_left)),
            Text('${_meses[_mes.month - 1]} ${_mes.year}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            IconButton(
                onPressed: () => _mudarMes(1),
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final s in _semana)
              Expanded(
                child: Center(
                  child: Text(s,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        //Uso de GridView para exibir calendario
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: celulas,
        ),
      ],
    );
  }
}

class _CelulaDia extends StatelessWidget {
  final int dia;
  final bool ehHoje;
  final int? prioridade;
  const _CelulaDia(
      {required this.dia, required this.ehHoje, required this.prioridade});

  @override
  Widget build(BuildContext context) {
    final cores = prioridade == null ? null : _coresPrioridade[prioridade]!;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cores?.$1 ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ehHoje ? _verdeEscuro : const Color(0xFFCCFBF1),
          width: ehHoje ? 2 : 1,
        ),
      ),
      child: Text('$dia',
          style: TextStyle(
            fontSize: 14,
            fontWeight: cores != null || ehHoje ? FontWeight.w800 : FontWeight.w500,
            color: cores?.$2 ?? const Color(0xFF334155),
          )),
    );
  }
}


// Legenda
class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    Widget item(Color cor, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                    color: cor, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 6),
            Text(texto, style: const TextStyle(fontSize: 12)),
          ],
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legenda do Calendário',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              item(_coresPrioridade[1]!.$1, 'Alta prioridade'),
              item(_coresPrioridade[2]!.$1, 'Média prioridade'),
              item(_coresPrioridade[3]!.$1, 'Baixa prioridade'),
            ],
          ),
        ],
      ),
    );
  }
}


// Plano de estudo (card)
class _CartaoPlano extends StatelessWidget {
  final PlanoEstudo plano;
  final VoidCallback onEditar;
  final VoidCallback onRemover;
  const _CartaoPlano(
      {required this.plano, required this.onEditar, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    const cinza = Color(0xFF475569);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFECFEFA), Color(0xFFCFF7FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child:
                    Icon(Icons.menu_book_outlined, size: 16, color: _verdeEscuro),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(plano.disciplina,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _verde, borderRadius: BorderRadius.circular(20)),
                child: Text(
                    PlanejamentoController.diasDaSemana[plano.diaSemana]!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              InkWell(
                  onTap: onEditar,
                  child: const Icon(Icons.edit_outlined,
                      size: 20, color: _verdeEscuro)),
              const SizedBox(width: 10),
              InkWell(
                  onTap: onRemover,
                  child: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.redAccent)),
            ],
          ),
          if (plano.topico.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(plano.topico,
                style: const TextStyle(color: cinza, fontSize: 14)),
          ],
          if (plano.resumoHorario.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: cinza),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(plano.resumoHorario,
                      style: const TextStyle(color: cinza, fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}


// Meta (card)
class _CartaoMeta extends StatelessWidget {
  final Meta meta;
  final VoidCallback onEditar;
  final VoidCallback onRemover;
  final VoidCallback onAlternar;
  const _CartaoMeta({
    required this.meta,
    required this.onEditar,
    required this.onRemover,
    required this.onAlternar,
  });

  @override
  Widget build(BuildContext context) {
    final concluida = meta.concluida;
    final icones = {
      1: Icons.error_outline,
      2: Icons.remove,
      3: Icons.arrow_downward,
    };
    final corPrioridade = meta.prioridade == 1
        ? const Color(0xFF0F172A)
        : _verdeEscuro;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: concluida ? const Color(0xFFF1F5F9) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: concluida
                  ? const Color(0xFFE2E8F0)
                  : meta.prioridade == 1
                      ? const Color(0xFF2DD4BF)
                      : const Color(0xFFB2F5EA)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEditar, // toque no card = editar
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(meta.titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration:
                                concluida ? TextDecoration.lineThrough : null,
                            color: concluida
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF0F172A),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(icones[meta.prioridade], size: 14, color: corPrioridade),
                          const SizedBox(width: 3),
                          Text('P${meta.prioridade}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: corPrioridade)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onAlternar,
                      child: Icon(
                        concluida
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 22,
                        color: concluida ? _verde : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (meta.descricao.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(meta.descricao,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 13)),
                ],
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(meta.categoria,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _verdeEscuro,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          meta.prazo.isEmpty ? 'Sem prazo' : meta.prazo,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 13)),
                    ),
                    InkWell(
                      onTap: onRemover,
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão com borda tracejada
// ---------------------------------------------------------------------------
class _BotaoTracejado extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotaoTracejado({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TracejadoPainter(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: _verdeEscuro, size: 20),
              const SizedBox(width: 8),
              Text(texto,
                  style: const TextStyle(
                      color: _verdeEscuro, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TracejadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(16));
    final path = Path()..addRRect(rrect);
    for (final metrica in path.computeMetrics()) {
      var d = 0.0;
      while (d < metrica.length) {
        canvas.drawPath(metrica.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Estrutura comum dos diálogos
// ---------------------------------------------------------------------------
class _DialogoForm extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String textoBotao;
  final GlobalKey<FormState> formKey;
  final List<Widget> campos;
  final VoidCallback onSalvar;

  const _DialogoForm({
    required this.icone,
    required this.titulo,
    required this.textoBotao,
    required this.formKey,
    required this.campos,
    required this.onSalvar,
  });

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
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFB2F5EA))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icone, color: _verdeEscuro, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(titulo,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            // Campos + botões
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...campos,
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF99F6E4)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Cancelar',
                                  style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: _gradiente,
                                  borderRadius: BorderRadius.circular(16)),
                              child: ElevatedButton(
                                onPressed: onSalvar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(textoBotao,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário: Plano de estudo
// ---------------------------------------------------------------------------
class _PlanoFormDialog extends StatefulWidget {
  final PlanejamentoController controller;
  final PlanoEstudo? plano;
  const _PlanoFormDialog({required this.controller, this.plano});

  @override
  State<_PlanoFormDialog> createState() => _PlanoFormDialogState();
}

class _PlanoFormDialogState extends State<_PlanoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _disciplina;
  late final TextEditingController _topico;
  late final TextEditingController _horario;
  late final TextEditingController _duracao;
  late int _dia;

  bool get _editando => widget.plano != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plano;
    _disciplina = TextEditingController(text: p?.disciplina ?? '');
    _topico = TextEditingController(text: p?.topico ?? '');
    _horario = TextEditingController(text: p?.horario ?? '');
    _duracao = TextEditingController(text: p?.duracao ?? '');
    _dia = p?.diaSemana ?? DateTime.monday;
  }

  @override
  void dispose() {
    _disciplina.dispose();
    _topico.dispose();
    _horario.dispose();
    _duracao.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    if (_editando) {
      widget.controller.editarPlano(widget.plano!.copyWith(
        disciplina: _disciplina.text.trim(),
        topico: _topico.text.trim(),
        diaSemana: _dia,
        horario: _horario.text.trim(),
        duracao: _duracao.text.trim(),
      ));
    } else {
      widget.controller.adicionarPlano(
        disciplina: _disciplina.text,
        topico: _topico.text,
        diaSemana: _dia,
        horario: _horario.text,
        duracao: _duracao.text,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _DialogoForm(
      icone: Icons.menu_book_outlined,
      titulo: _editando ? 'Editar Plano de Estudo' : 'Novo Plano de Estudo',
      textoBotao: _editando ? 'Salvar' : 'Adicionar',
      formKey: _formKey,
      onSalvar: _salvar,
      campos: [
        _rotulo('Dia da Semana'),
        DropdownButtonFormField<int>(
          initialValue: _dia,
          decoration: _decoracao(''),
          items: PlanejamentoController.diasDaSemana.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _dia = v ?? _dia),
        ),
        _rotulo('Disciplina *'),
        TextFormField(
          controller: _disciplina,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoracao('Ex: Economia e Finanças'),
          validator: _obrigatorio,
        ),
        _rotulo('Tópico *'),
        TextFormField(
          controller: _topico,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoracao('Ex: Estrutura de mercado'),
          validator: _obrigatorio,
        ),
        _rotulo('Horário'),
        TextFormField(
          controller: _horario,
          keyboardType: TextInputType.datetime,
          decoration: _decoracao('Ex: 09:30 - 13:00'),
        ),
        _rotulo('Duração'),
        TextFormField(
          controller: _duracao,
          decoration: _decoracao('Ex: 2h'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário: Meta
// ---------------------------------------------------------------------------
class _MetaFormDialog extends StatefulWidget {
  final PlanejamentoController controller;
  final Meta? meta;
  const _MetaFormDialog({required this.controller, this.meta});

  @override
  State<_MetaFormDialog> createState() => _MetaFormDialogState();
}

class _MetaFormDialogState extends State<_MetaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late final TextEditingController _prazo;
  late final TextEditingController _categoria;
  late int _prioridade;

  bool get _editando => widget.meta != null;

  @override
  void initState() {
    super.initState();
    final m = widget.meta;
    _titulo = TextEditingController(text: m?.titulo ?? '');
    _descricao = TextEditingController(text: m?.descricao ?? '');
    _prazo = TextEditingController(text: m?.prazo ?? '');
    _categoria = TextEditingController(text: m?.categoria ?? 'Geral');
    _prioridade = m?.prioridade ?? 2;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _prazo.dispose();
    _categoria.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final categoria =
        _categoria.text.trim().isEmpty ? 'Geral' : _categoria.text.trim();

    if (_editando) {
      widget.controller.editarMeta(widget.meta!.copyWith(
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        categoria: categoria,
        prazo: _prazo.text.trim(),
        prioridade: _prioridade,
      ));
    } else {
      widget.controller.adicionarMeta(
        titulo: _titulo.text,
        descricao: _descricao.text,
        categoria: categoria,
        prazo: _prazo.text,
        prioridade: _prioridade,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _DialogoForm(
      icone: Icons.track_changes,
      titulo: _editando ? 'Editar Meta' : 'Nova Meta',
      textoBotao: _editando ? 'Salvar' : 'Adicionar',
      formKey: _formKey,
      onSalvar: _salvar,
      campos: [
        _rotulo('Título da Meta *'),
        TextFormField(
          controller: _titulo,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoracao('Ex: Completar 5 listas de exercícios'),
          validator: _obrigatorio,
        ),
        _rotulo('Descrição'),
        TextFormField(
          controller: _descricao,
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: 4,
          decoration: _decoracao('Detalhes da meta...'),
        ),
        _rotulo('Prioridade'),
        DropdownButtonFormField<int>(
          initialValue: _prioridade,
          decoration: _decoracao(''),
          items: PlanejamentoController.nomesPrioridade.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _prioridade = v ?? _prioridade),
        ),
        _rotulo('Prazo'),
        TextFormField(
          controller: _prazo,
          decoration: _decoracao('Ex: Até Sexta ou 30/03/2026'),
        ),
        _rotulo('Categoria'),
        TextFormField(
          controller: _categoria,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoracao('Ex: Geral'),
        ),
      ],
    );
  }
}