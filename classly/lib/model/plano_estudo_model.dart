import 'package:cloud_firestore/cloud_firestore.dart';

class PlanoEstudo {
  final String id; // id do documento no Firestore ('' enquanto não foi salvo)
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

  // ---- Firestore ----

  /// Converte um documento da coleção "planos" em [PlanoEstudo].
  factory PlanoEstudo.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return PlanoEstudo(
      id: doc.id,
      disciplina: (d['disciplina'] ?? '') as String,
      topico: (d['topico'] ?? '') as String,
      diaSemana: (d['diaSemana'] ?? DateTime.monday) as int,
      horario: (d['horario'] ?? '') as String,
      duracao: (d['duracao'] ?? '') as String,
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
      'disciplina': disciplina,
      'topico': topico,
      'diaSemana': diaSemana,
      'horario': horario,
      'duracao': duracao,
    };
  }
}