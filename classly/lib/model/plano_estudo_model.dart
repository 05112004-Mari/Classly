class PlanoEstudo {
  final String id;
  final String disciplina;
  final String topico;
  final int diaSemana; // DateTime.monday (1) ... DateTime.sunday (7)
  final String horario; // texto livre, ex: "09:30 - 13:00"
  final String duracao; // texto livre, ex: "2h"

  const PlanoEstudo({
    required this.id,
    required this.disciplina,
    required this.topico,
    required this.diaSemana,
    this.horario = '',
    this.duracao = '',
  });

  /// "09:30 - 13:00  •  2h" (só o que foi preenchido)
  String get resumoHorario => [horario, duracao]
      .where((e) => e.trim().isNotEmpty)
      .join('  •  ');

  PlanoEstudo copyWith({
    String? disciplina,
    String? topico,
    int? diaSemana,
    String? horario,
    String? duracao,
  }) {
    return PlanoEstudo(
      id: id,
      disciplina: disciplina ?? this.disciplina,
      topico: topico ?? this.topico,
      diaSemana: diaSemana ?? this.diaSemana,
      horario: horario ?? this.horario,
      duracao: duracao ?? this.duracao,
    );
  }
}