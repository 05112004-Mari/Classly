class Meta {
  final String id;
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
    required this.categoria,
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
}