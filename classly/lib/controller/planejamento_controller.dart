import 'package:classly/model/meta_model.dart';
import 'package:classly/model/plano_estudo_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanejamentoController {
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

  // Coleções "planos" e "metas" do Firestore
  final CollectionReference<Map<String, dynamic>> _planos =
      FirebaseFirestore.instance.collection('planos');
  final CollectionReference<Map<String, dynamic>> _metas =
      FirebaseFirestore.instance.collection('metas');

  static const Duration _limite = Duration(seconds: 10);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ---------------- Leitura em tempo real ----------------

  Stream<List<PlanoEstudo>> planosDoUsuario() {
    return _planos
        .where('uid', isEqualTo: _uid ?? '')
        .snapshots()
        .map((snap) => snap.docs.map(PlanoEstudo.fromDoc).toList());
  }

  Stream<List<Meta>> metasDoUsuario() {
    return _metas
        .where('uid', isEqualTo: _uid ?? '')
        .snapshots()
        .map((snap) => snap.docs.map(Meta.fromDoc).toList());
  }

  // ---------------- Ordenação ----------------

  /// Por dia da semana e depois por horário.
  static List<PlanoEstudo> ordenarPlanos(List<PlanoEstudo> planos) {
    return [...planos]..sort((a, b) {
        final porDia = a.diaSemana.compareTo(b.diaSemana);
        return porDia != 0 ? porDia : a.horario.compareTo(b.horario);
      });
  }

  /// Pendentes primeiro, depois por prioridade (alta, média, baixa).
  static List<Meta> ordenarMetas(List<Meta> metas) {
    return [...metas]..sort((a, b) {
        if (a.concluida != b.concluida) return a.concluida ? 1 : -1;
        return a.prioridade.compareTo(b.prioridade);
      });
  }

  // ---------------- Planos de estudo ----------------

  Future<void> adicionarPlano({
    required String disciplina,
    required String topico,
    required int diaSemana,
    String horario = '',
    String duracao = '',
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Usuário não autenticado.');

    final plano = PlanoEstudo(
      id: '',
      disciplina: disciplina.trim(),
      topico: topico.trim(),
      diaSemana: diaSemana,
      horario: horario.trim(),
      duracao: duracao.trim(),
    );
    await _planos.add(plano.toMap(uid)).timeout(_limite);
  }

  Future<void> editarPlano(PlanoEstudo atualizado) async {
    await _planos
        .doc(atualizado.id)
        .update(atualizado.toUpdateMap())
        .timeout(_limite);
  }

  Future<void> removerPlano(String id) async {
    await _planos.doc(id).delete().timeout(_limite);
  }

  // ---------------- Metas ----------------

  Future<void> adicionarMeta({
    required String titulo,
    String descricao = '',
    required String categoria,
    String prazo = '',
    required int prioridade,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Usuário não autenticado.');

    final meta = Meta(
      id: '',
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      categoria: categoria.trim().isEmpty ? 'Geral' : categoria.trim(),
      prazo: prazo.trim(),
      prioridade: prioridade,
    );
    await _metas.add(meta.toMap(uid)).timeout(_limite);
  }

  Future<void> editarMeta(Meta atualizada) async {
    await _metas
        .doc(atualizada.id)
        .update(atualizada.toUpdateMap())
        .timeout(_limite);
  }

  Future<void> alternarConclusaoMeta(Meta meta) async {
    await _metas
        .doc(meta.id)
        .update({'concluida': !meta.concluida}).timeout(_limite);
  }

  Future<void> removerMeta(String id) async {
    await _metas.doc(id).delete().timeout(_limite);
  }

  // ---------------- Calendário ----------------

  /// Lê o texto do prazo: aceita data (dd/mm/aaaa) ou nome de um dia da
  /// semana ("Até Sexta" = próxima sexta). Outros textos não marcam o calendário.
  static DateTime? _dataDoPrazo(String prazo, DateTime hoje) {
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
  static Map<DateTime, int> prioridadePorData(List<Meta> metas) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final mapa = <DateTime, int>{};
    for (final m in metas.where((m) => !m.concluida)) {
      final data = _dataDoPrazo(m.prazo, hoje);
      if (data == null) continue;
      final atual = mapa[data];
      if (atual == null || m.prioridade < atual) mapa[data] = m.prioridade;
    }
    return mapa;
  }
}