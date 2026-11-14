import 'package:cloud_firestore/cloud_firestore.dart';

class Meta {
  final String id; // id do documento no Firestore ('' enquanto não foi salva)
  final String titulo;
  final String descricao;
  final String categoria;
  final String prazo; // texto livre, ex: "Até Sexta" ou "30/03/2026"
  final int prioridade; // 1 = alta, 2 = média, 3 = baixa
  final bool concluida;

  const Meta({
    required this.id,
    required this.titulo,
    this.descricao = '',
    this.categoria = 'Geral',
    this.prazo = '',
    required this.prioridade,
    this.concluida = false,
  });

  Meta copyWith({
    String? titulo,
    String? descricao,
    String? categoria,
    String? prazo,
    int? prioridade,
    bool? concluida,
  }) {
    return Meta(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prazo: prazo ?? this.prazo,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
    );
  }

  // ---- Firestore ----

  /// Converte um documento da coleção "metas" em [Meta].
  factory Meta.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Meta(
      id: doc.id,
      titulo: (d['titulo'] ?? '') as String,
      descricao: (d['descricao'] ?? '') as String,
      categoria: (d['categoria'] ?? 'Geral') as String,
      prazo: (d['prazo'] ?? '') as String,
      prioridade: (d['prioridade'] ?? 2) as int,
      concluida: (d['concluida'] ?? false) as bool,
    );
  }

  /// Campos gravados ao CRIAR. O "uid" separa os dados por usuário.
  Map<String, dynamic> toMap(String uid) {
    return {
      'uid': uid,
      ...toUpdateMap(),
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }

  /// Campos atualizados ao EDITAR (uid e criadoEm não mudam).
  Map<String, dynamic> toUpdateMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'prazo': prazo,
      'prioridade': prioridade,
      'concluida': concluida,
    };
  }
}