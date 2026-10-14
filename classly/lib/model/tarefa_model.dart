import 'package:flutter/material.dart';

enum StatusTarefa { aFazer, emAndamento, concluido }

extension StatusTarefaX on StatusTarefa {
  String get nome => switch (this) {
        StatusTarefa.aFazer => 'A Fazer',
        StatusTarefa.emAndamento => 'Em Andamento',
        StatusTarefa.concluido => 'Concluído',
      };
}

String formatarDataBr(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String formatarHoraBr(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class Tarefa {
  final String id;
  final String titulo;
  final String disciplina;
  final String descricao;
  final DateTime? data;
  final TimeOfDay? hora;
  final int prioridade; // 1 = alta, 2 = média, 3 = baixa
  final StatusTarefa status;

  const Tarefa({
    required this.id,
    required this.titulo,
    this.disciplina = '',
    this.descricao = '',
    this.data,
    this.hora,
    required this.prioridade,
    required this.status,
  });

  /// Data + hora juntas (usado para ordenar). Nulo se não tiver data.
  DateTime? get dataHora {
    final d = data;
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day, hora?.hour ?? 0, hora?.minute ?? 0);
  }

  /// "26/03/2026 • 11:20" (só o que foi preenchido)
  String get dataHoraTexto {
    final partes = <String>[];
    final d = data;
    final h = hora;
    if (d != null) partes.add(formatarDataBr(d));
    if (h != null) partes.add(formatarHoraBr(h));
    return partes.join(' • ');
  }

  Tarefa comStatus(StatusTarefa novo) => Tarefa(
        id: id,
        titulo: titulo,
        disciplina: disciplina,
        descricao: descricao,
        data: data,
        hora: hora,
        prioridade: prioridade,
        status: novo,
      );
}