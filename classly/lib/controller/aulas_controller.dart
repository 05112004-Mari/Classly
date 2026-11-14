import 'package:classly/model/aula_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AulasController {
  static const Map<int, String> diasDaSemana = {
    DateTime.monday: 'Segunda-feira',
    DateTime.tuesday: 'Terça-feira',
    DateTime.wednesday: 'Quarta-feira',
    DateTime.thursday: 'Quinta-feira',
    DateTime.friday: 'Sexta-feira',
    DateTime.saturday: 'Sábado',
  };

  // Coleção "aulas" do Firestore
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('aulas');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ---- Leitura em tempo real (usada pelo StreamBuilder da view) ----

  /// Escuta só as aulas do usuário logado. Sempre que o Firestore muda
  /// (inclusão, edição ou remoção), a lista é emitida de novo.
  Stream<List<Aula>> aulasDoUsuario() {
    return _colecao
        .where('uid', isEqualTo: _uid ?? '')
        .snapshots()
        .map((snap) => snap.docs.map(Aula.fromDoc).toList());
  }

  // ---- Consultas sobre a lista recebida ----

  /// Dias que têm pelo menos uma aula, em ordem.
  static List<int> diasComAula(List<Aula> aulas) {
    return aulas.map((a) => a.diaSemana).toSet().toList()..sort();
  }

  /// Aulas de um dia, ordenadas pelo horário de início.
  static List<Aula> aulasDoDia(List<Aula> aulas, int dia) {
    return aulas.where((a) => a.diaSemana == dia).toList()
      ..sort((a, b) => a.inicioEmMinutos.compareTo(b.inicioEmMinutos));
  }

  // ---- Resumo semanal ----
  static int totalDisciplinas(List<Aula> aulas) =>
      aulas.map((a) => a.disciplina.trim().toLowerCase()).toSet().length;

  static int diasLetivos(List<Aula> aulas) => diasComAula(aulas).length;

  static double horasPorSemana(List<Aula> aulas) =>
      aulas.fold(0.0, (soma, a) => soma + a.duracaoEmHoras);

  // ---- CRUD no Firestore ----
  // Os métodos lançam exceção se algo falhar; a view mostra a mensagem.

  Future<void> adicionar({
    required String disciplina,
    required int diaSemana,
    required TimeOfDay inicio,
    required TimeOfDay fim,
    required String sala,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Usuário não autenticado.');

    final aula = Aula(
      id: '', // o Firestore gera o id do documento
      disciplina: disciplina.trim(),
      diaSemana: diaSemana,
      inicio: inicio,
      fim: fim,
      sala: sala.trim(),
    );
    await _colecao.add(aula.toMap(uid));
  }

  Future<void> editar(Aula atualizada) async {
    await _colecao.doc(atualizada.id).update(atualizada.toUpdateMap());
  }

  Future<void> remover(String id) async {
    await _colecao.doc(id).delete();
  }
}