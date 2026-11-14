import 'package:classly/model/tarefa_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KanbanController {
  // Coleção "kanban" do Firestore
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('kanban');

  static const Duration _limite = Duration(seconds: 10);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ---- Leitura em tempo real (StreamBuilder) ----

  /// Escuta só as tarefas do Kanban do usuário logado.
  Stream<List<Tarefa>> tarefasDoUsuario() {
    return _colecao
        .where('uid', isEqualTo: _uid ?? '')
        .snapshots()
        .map((snap) => snap.docs.map(Tarefa.fromDoc).toList());
  }

  // ---- Consultas sobre a lista recebida ----

  /// Tarefas de uma coluna: primeiro as com data mais próxima,
  /// depois (empate ou sem data) por prioridade.
  static List<Tarefa> tarefasDoStatus(List<Tarefa> todas, StatusTarefa status) {
    final lista = todas.where((t) => t.status == status).toList()
      ..sort((a, b) {
        final da = a.dataHora;
        final db = b.dataHora;
        if (da != null && db != null) {
          final c = da.compareTo(db);
          if (c != 0) return c;
        } else if (da != null) {
          return -1;
        } else if (db != null) {
          return 1;
        }
        return a.prioridade.compareTo(b.prioridade);
      });
    return lista;
  }

  static int contar(List<Tarefa> todas, StatusTarefa status) =>
      todas.where((t) => t.status == status).length;

  // ---- CRUD no Firestore (lançam exceção se falhar) ----

  Future<void> adicionar({
    required String titulo,
    String disciplina = '',
    String descricao = '',
    DateTime? data,
    TimeOfDay? hora,
    required int prioridade,
    StatusTarefa status = StatusTarefa.aFazer,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Usuário não autenticado.');

    final tarefa = Tarefa(
      id: '', // o Firestore gera o id do documento
      titulo: titulo.trim(),
      disciplina: disciplina.trim(),
      descricao: descricao.trim(),
      data: data,
      hora: hora,
      prioridade: prioridade,
      status: status,
    );
    await _colecao.add(tarefa.toMap(uid)).timeout(_limite);
  }

  Future<void> editar(Tarefa atualizada) async {
    await _colecao
        .doc(atualizada.id)
        .update(atualizada.toUpdateMap())
        .timeout(_limite);
  }

  Future<void> mover(String id, StatusTarefa novoStatus) async {
    await _colecao
        .doc(id)
        .update({'status': novoStatus.name}).timeout(_limite);
  }

  Future<void> remover(String id) async {
    await _colecao.doc(id).delete().timeout(_limite);
  }
}