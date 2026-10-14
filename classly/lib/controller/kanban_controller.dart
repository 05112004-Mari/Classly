import 'package:flutter/material.dart';
import 'package:classly/model/tarefa_model.dart';

class KanbanController extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];

  /// Tarefas de uma coluna: primeiro as com data mais próxima,
  /// depois (empate ou sem data) por prioridade.
  List<Tarefa> tarefasDoStatus(StatusTarefa status) {
    final lista = _tarefas.where((t) => t.status == status).toList()
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

  int contar(StatusTarefa status) =>
      _tarefas.where((t) => t.status == status).length;

  void adicionar({
    required String titulo,
    String disciplina = '',
    String descricao = '',
    DateTime? data,
    TimeOfDay? hora,
    required int prioridade,
    StatusTarefa status = StatusTarefa.aFazer,
  }) {
    _tarefas.add(Tarefa(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      disciplina: disciplina.trim(),
      descricao: descricao.trim(),
      data: data,
      hora: hora,
      prioridade: prioridade,
      status: status,
    ));
    notifyListeners();
  }

  void editar(Tarefa atualizada) {
    final i = _tarefas.indexWhere((t) => t.id == atualizada.id);
    if (i == -1) return;
    _tarefas[i] = atualizada;
    notifyListeners();
  }

  void mover(String id, StatusTarefa novoStatus) {
    final i = _tarefas.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tarefas[i] = _tarefas[i].comStatus(novoStatus);
    notifyListeners();
  }

  void remover(String id) {
    _tarefas.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}