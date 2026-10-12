import 'package:flutter/material.dart';

class Aula {
  final String id;
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
}

String formatarHora(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';