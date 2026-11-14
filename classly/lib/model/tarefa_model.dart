import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String id; // id do documento no Firestore ('' enquanto não foi salva)
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

  // ---- Firestore ----

  /// Converte um documento da coleção "kanban" em [Tarefa].
  factory Tarefa.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final ts = d['data'];
    final texto = (d['hora'] ?? '') as String;

    TimeOfDay? hora;
    if (texto.contains(':')) {
      final p = texto.split(':');
      hora = TimeOfDay(
        hour: int.tryParse(p[0]) ?? 0,
        minute: int.tryParse(p[1]) ?? 0,
      );
    }

    return Tarefa(
      id: doc.id,
      titulo: (d['titulo'] ?? '') as String,
      disciplina: (d['disciplina'] ?? '') as String,
      descricao: (d['descricao'] ?? '') as String,
      data: ts is Timestamp ? ts.toDate() : null,
      hora: hora,
      prioridade: (d['prioridade'] ?? 2) as int,
      status: StatusTarefa.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => StatusTarefa.aFazer,
      ),
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
      'disciplina': disciplina,
      'descricao': descricao,
      'data': data == null ? null : Timestamp.fromDate(data!),
      'hora': hora == null ? '' : formatarHoraBr(hora!),
      'prioridade': prioridade,
      'status': status.name,
    };
  }
}