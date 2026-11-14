import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Aula {
  final String id; // id do documento no Firestore ('' enquanto não foi salva)
  final String disciplina;
  final int diaSemana; // DateTime.monday (1) ... DateTime.saturday (6)
  final TimeOfDay inicio;
  final TimeOfDay fim;
  final String sala;

  const Aula({
    required this.id,
    required this.disciplina,
    required this.diaSemana,
    required this.inicio,
    required this.fim,
    required this.sala,
  });

  int get inicioEmMinutos => inicio.hour * 60 + inicio.minute;
  int get fimEmMinutos => fim.hour * 60 + fim.minute;
  double get duracaoEmHoras => (fimEmMinutos - inicioEmMinutos) / 60;

  Aula copyWith({
    String? disciplina,
    int? diaSemana,
    TimeOfDay? inicio,
    TimeOfDay? fim,
    String? sala,
  }) {
    return Aula(
      id: id,
      disciplina: disciplina ?? this.disciplina,
      diaSemana: diaSemana ?? this.diaSemana,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      sala: sala ?? this.sala,
    );
  }

  // ---- Firestore ----

  /// Converte um documento da coleção "aulas" em [Aula].
  factory Aula.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Aula(
      id: doc.id,
      disciplina: (d['disciplina'] ?? '') as String,
      diaSemana: (d['diaSemana'] ?? DateTime.monday) as int,
      inicio: _lerHora((d['inicio'] ?? '00:00') as String),
      fim: _lerHora((d['fim'] ?? '00:00') as String),
      sala: (d['sala'] ?? '') as String,
    );
  }

  /// Campos gravados ao CRIAR a aula. O "uid" separa os dados por usuário.
  Map<String, dynamic> toMap(String uid) {
    return {
      'uid': uid,
      'disciplina': disciplina,
      'diaSemana': diaSemana,
      'inicio': formatarHora(inicio),
      'fim': formatarHora(fim),
      'sala': sala,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }

  /// Campos atualizados ao EDITAR a aula (uid e criadoEm não mudam).
  Map<String, dynamic> toUpdateMap() {
    return {
      'disciplina': disciplina,
      'diaSemana': diaSemana,
      'inicio': formatarHora(inicio),
      'fim': formatarHora(fim),
      'sala': sala,
    };
  }

  static TimeOfDay _lerHora(String texto) {
    final partes = texto.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 0,
      minute: partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
    );
  }
}

String formatarHora(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';