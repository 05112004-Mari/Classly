  import 'package:flutter/material.dart';
  import 'package:classly/model/aula_model.dart';
  import 'package:classly/controller/aulas_controller.dart';
  
const _verde = Color(0xFF00BFA5);
const _verdeEscuro = Color(0xFF00897B);
const _gradiente = LinearGradient(
  colors: [Color(0xFF00D4B4), Color(0xFF00917F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Cores (fundo, borda) alternadas entre as aulas de um mesmo dia.
const _paletas = [
  (Color(0xFFECFEFA), Color(0xFFB2F5EA)),
  (Color(0xFFCCFBF1), Color(0xFF5EEAD4)),
  (Color(0xFFCFF7FE), Color(0xFF67E8F9)),
  (Color(0xFF99F6E4), Color(0xFF2DD4BF)),
];

class AulasView extends StatefulWidget {
  const AulasView({super.key});

  @override
  State<AulasView> createState() => _AulasViewState();
}

class _AulasViewState extends State<AulasView> {
  final AulasController _controller = AulasController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([Aula? aula]) {
    return showDialog(
      context: context,
      builder: (_) => _AulaFormDialog(controller: _controller, aula: aula),
    );
  }

  Future<void> _confirmarRemocao(Aula aula) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover aula'),
        content: Text('Deseja remover "${aula.disciplina}"?'),
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
    if (confirmou == true) _controller.remover(aula.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                const Text('Minhas Aulas',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Grade horária semanal',
                    style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 20),
                if (_controller.aulas.isEmpty)
                  const _EstadoVazio()
                else ...[
                  for (final dia in _controller.diasComAula)
                    _CartaoDia(
                      titulo: AulasController.diasDaSemana[dia]!,
                      aulas: _controller.aulasDoDia(dia),
                      onEditar: _abrirFormulario,
                      onRemover: _confirmarRemocao,
                    ),
                  _ResumoSemanal(controller: _controller),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: Color(0xFF99F6E4)),
          SizedBox(height: 12),
          Text('Nenhuma aula cadastrada',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155))),
          SizedBox(height: 4),
          Text('Toque no + para adicionar sua primeira aula',
              style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _CartaoDia extends StatelessWidget {
  final String titulo;
  final List<Aula> aulas;
  final void Function(Aula) onEditar;
  final void Function(Aula) onRemover;

  const _CartaoDia({
    required this.titulo,
    required this.aulas,
    required this.onEditar,
    required this.onRemover,
  });

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
                child: const Icon(Icons.calendar_today_outlined,
                    color: _verdeEscuro, size: 22),
              ),
              const SizedBox(width: 12),
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < aulas.length; i++)
            _CartaoAula(
              aula: aulas[i],
              cores: _paletas[i % _paletas.length],
              onEditar: () => onEditar(aulas[i]),
              onRemover: () => onRemover(aulas[i]),
            ),
        ],
      ),
    );
  }
}

class _CartaoAula extends StatelessWidget {
  final Aula aula;
  final (Color, Color) cores;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _CartaoAula({
    required this.aula,
    required this.cores,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    const cinza = Color(0xFF475569);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cores.$1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cores.$2),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.menu_book_outlined,
                          size: 18, color: _verdeEscuro),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(aula.disciplina,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    InkWell(
                      onTap: onRemover,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline,
                            size: 20, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: cinza),
                  const SizedBox(width: 6),
                  Text('${formatarHora(aula.inicio)} - ${formatarHora(aula.fim)}',
                      style: const TextStyle(color: cinza, fontSize: 13)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: cinza),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(aula.sala,
                        style: const TextStyle(color: cinza, fontSize: 13)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumoSemanal extends StatelessWidget {
  final AulasController controller;
  const _ResumoSemanal({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: _gradiente, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo Semanal',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(children: [
            _Metrica('Total de Aulas', '${controller.totalAulas}'),
            _Metrica('Horas/Semana',
                '${controller.horasPorSemana.toStringAsFixed(1)}h'),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _Metrica('Disciplinas', '${controller.totalDisciplinas}'),
            _Metrica('Dias Letivos', '${controller.diasLetivos}'),
          ]),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _Metrica(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário (Nova Aula / Editar Aula)
// ---------------------------------------------------------------------------
class _AulaFormDialog extends StatefulWidget {
  final AulasController controller;
  final Aula? aula;
  const _AulaFormDialog({required this.controller, this.aula});

  @override
  State<_AulaFormDialog> createState() => _AulaFormDialogState();
}

class _AulaFormDialogState extends State<_AulaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _disciplina;
  late final TextEditingController _sala;
  late final TextEditingController _inicioTxt;
  late final TextEditingController _fimTxt;
  late int _dia;
  TimeOfDay? _inicio;
  TimeOfDay? _fim;

  bool get _editando => widget.aula != null;

  @override
  void initState() {
    super.initState();
    final a = widget.aula;
    _disciplina = TextEditingController(text: a?.disciplina ?? '');
    _sala = TextEditingController(text: a?.sala ?? '');
    _dia = a?.diaSemana ?? DateTime.monday;
    _inicio = a?.inicio;
    _fim = a?.fim;
    _inicioTxt = TextEditingController(
        text: a != null ? formatarHora(a.inicio) : '');
    _fimTxt =
        TextEditingController(text: a != null ? formatarHora(a.fim) : '');
  }

  @override
  void dispose() {
    _disciplina.dispose();
    _sala.dispose();
    _inicioTxt.dispose();
    _fimTxt.dispose();
    super.dispose();
  }

  Future<void> _escolherHora(bool inicio) async {
    final atual = (inicio ? _inicio : _fim) ?? const TimeOfDay(hour: 8, minute: 0);
    final t = await showTimePicker(
      context: context,
      initialTime: atual,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null) return;
    setState(() {
      if (inicio) {
        _inicio = t;
        _inicioTxt.text = formatarHora(t);
      } else {
        _fim = t;
        _fimTxt.text = formatarHora(t);
      }
    });
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final inicio = _inicio!;
    final fim = _fim!;

    if (fim.hour * 60 + fim.minute <= inicio.hour * 60 + inicio.minute) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('O término deve ser depois do início')));
      return;
    }

    if (_editando) {
      widget.controller.editar(widget.aula!.copyWith(
        disciplina: _disciplina.text.trim(),
        diaSemana: _dia,
        inicio: inicio,
        fim: fim,
        sala: _sala.text.trim(),
      ));
    } else {
      widget.controller.adicionar(
        disciplina: _disciplina.text,
        diaSemana: _dia,
        inicio: inicio,
        fim: fim,
        sala: _sala.text,
      );
    }
    Navigator.pop(context);
  }

  InputDecoration _decoracao(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(gradient: _gradiente),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_editando ? 'Editar Aula' : 'Nova Aula',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rotulo('Disciplina *'),
                    TextFormField(
                      controller: _disciplina,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoracao('Ex: Matemática'),
                      validator: _obrigatorio,
                    ),
                    _rotulo('Dia da Semana *'),
                    DropdownButtonFormField<int>(
                     initialValue: _dia,
                      decoration: _decoracao(''),
                      items: AulasController.diasDaSemana.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _dia = v ?? _dia),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rotulo('Início *'),
                              TextFormField(
                                controller: _inicioTxt,
                                readOnly: true,
                                onTap: () => _escolherHora(true),
                                decoration: _decoracao('--:--'),
                                validator: _obrigatorio,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rotulo('Término *'),
                              TextFormField(
                                controller: _fimTxt,
                                readOnly: true,
                                onTap: () => _escolherHora(false),
                                decoration: _decoracao('--:--'),
                                validator: _obrigatorio,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _rotulo('Sala *'),
                    TextFormField(
                      controller: _sala,
                      decoration: _decoracao('Ex: Sala 12, Laboratório 3'),
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: _gradiente,
                            borderRadius: BorderRadius.circular(16)),
                        child: ElevatedButton(
                          onPressed: _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                              _editando ? 'Salvar Alterações' : 'Adicionar Aula',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
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