import 'package:flutter/material.dart';
import 'package:classly/model/meta_model.dart';
import 'package:classly/model/plano_estudo_model.dart';

class PlanejamentoController extends ChangeNotifier {
  static const Map<int, String> diasDaSemana = {
    DateTime.monday: 'Segunda',
    DateTime.tuesday: 'Terça',
    DateTime.wednesday: 'Quarta',
    DateTime.thursday: 'Quinta',
    DateTime.friday: 'Sexta',
    DateTime.saturday: 'Sábado',
    DateTime.sunday: 'Domingo',
  };

  static const Map<int, String> nomesPrioridade = {
    1: 'Alta',
    2: 'Média',
    3: 'Baixa',
  };

  final List<PlanoEstudo> _planos = [];
  final List<Meta> _metas = [];

  String _novoId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---------------- Planos de estudo ----------------
  List<PlanoEstudo> get planos {
    final lista = [..._planos]..sort((a, b) {
        final porDia = a.diaSemana.compareTo(b.diaSemana);
        return porDia != 0 ? porDia : a.horario.compareTo(b.horario);
      });
    return lista;
  }

  void adicionarPlano({
    required String disciplina,
    required String topico,
    required int diaSemana,
    String horario = '',
    String duracao = '',
  }) {
    _planos.add(PlanoEstudo(
      id: _novoId(),
      disciplina: disciplina.trim(),
      topico: topico.trim(),
      diaSemana: diaSemana,
      horario: horario.trim(),
      duracao: duracao.trim(),
    ));
    notifyListeners();
  }

  void editarPlano(PlanoEstudo atualizado) {
    final i = _planos.indexWhere((p) => p.id == atualizado.id);
    if (i == -1) return;
    _planos[i] = atualizado;
    notifyListeners();
  }

  void removerPlano(String id) {
    _planos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ---------------- Metas ----------------
  /// Pendentes primeiro, depois por prioridade (alta, média, baixa).
  List<Meta> get metas {
    final lista = [..._metas]..sort((a, b) {
        if (a.concluida != b.concluida) return a.concluida ? 1 : -1;
        return a.prioridade.compareTo(b.prioridade);
      });
    return lista;
  }

  void adicionarMeta({
    required String titulo,
    String descricao = '',
    required String categoria,
    String prazo = '',
    required int prioridade,
  }) {
    _metas.add(Meta(
      id: _novoId(),
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      categoria: categoria.trim().isEmpty ? 'Geral' : categoria.trim(),
      prazo: prazo.trim(),
      prioridade: prioridade,
    ));
    notifyListeners();
  }

  void editarMeta(Meta atualizada) {
    final i = _metas.indexWhere((m) => m.id == atualizada.id);
    if (i == -1) return;
    _metas[i] = atualizada;
    notifyListeners();
  }

  void alternarConclusaoMeta(String id) {
    final i = _metas.indexWhere((m) => m.id == id);
    if (i == -1) return;
    _metas[i] = _metas[i].copyWith(concluida: !_metas[i].concluida);
    notifyListeners();
  }

  void removerMeta(String id) {
    _metas.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ---------------- Calendário ----------------
  /// Lê o texto do prazo: aceita data (dd/mm/aaaa) ou nome de um dia da
  /// semana ("Até Sexta" = próxima sexta). Outros textos não marcam o calendário.
  DateTime? _dataDoPrazo(String prazo, DateTime hoje) {
    final texto = prazo.toLowerCase();

    final data = RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(texto);
    if (data != null) {
      final d = int.parse(data.group(1)!);
      final m = int.parse(data.group(2)!);
      final a = int.parse(data.group(3)!);
      final resultado = DateTime(a, m, d);
      return (resultado.day == d && resultado.month == m) ? resultado : null;
    }

    const nomes = {
      'segunda': DateTime.monday,
      'terça': DateTime.tuesday,
      'terca': DateTime.tuesday,
      'quarta': DateTime.wednesday,
      'quinta': DateTime.thursday,
      'sexta': DateTime.friday,
      'sábado': DateTime.saturday,
      'sabado': DateTime.saturday,
      'domingo': DateTime.sunday,
    };
    for (final e in nomes.entries) {
      if (texto.contains(e.key)) {
        final dias = (e.value - hoje.weekday + 7) % 7;
        return DateTime(hoje.year, hoje.month, hoje.day + dias);
      }
    }
    return null;
  }

  /// Para cada meta pendente com prazo reconhecido, marca a data com a
  /// maior prioridade (menor número).
  Map<DateTime, int> get prioridadePorData {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final mapa = <DateTime, int>{};
    for (final m in _metas.where((m) => !m.concluida)) {
      final data = _dataDoPrazo(m.prazo, hoje);
      if (data == null) continue;
      final atual = mapa[data];
      if (atual == null || m.prioridade < atual) mapa[data] = m.prioridade;
    }
    return mapa;
  }
}