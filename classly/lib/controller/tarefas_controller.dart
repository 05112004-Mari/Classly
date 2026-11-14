import 'package:classly/view/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarefasController {
  // Coleção "tarefas" do Firestore (tarefas e provas ficam juntas: isExam)
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('tarefas');

  static const Duration _limite = Duration(seconds: 10);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ---- Leitura em tempo real (StreamBuilder) ----

  /// Escuta só as tarefas/provas do usuário logado.
  Stream<List<Task>> tarefasDoUsuario() {
    return _colecao
        .where('uid', isEqualTo: _uid ?? '')
        .snapshots()
        .map((snap) => snap.docs.map(Task.fromDoc).toList());
  }

  // ---- Consultas sobre a lista recebida ----

  static List<Task> tarefas(List<Task> itens) =>
      itens.where((t) => !t.isExam).toList();

  static List<Task> provas(List<Task> itens) =>
      itens.where((t) => t.isExam).toList();

  /// Tarefas pendentes, da maior para a menor prioridade.
  static List<Task> pendentes(List<Task> itens) {
    final lista = tarefas(itens).where((t) => !t.completed).toList();
    lista.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return lista;
  }

  static List<Task> concluidas(List<Task> itens) =>
      tarefas(itens).where((t) => t.completed).toList();

  static ({int total, int completed, double studiedHours}) resumo(
      List<Task> itens) {
    final lista = tarefas(itens);
    final feitas = lista.where((t) => t.completed).length;
    return (total: lista.length, completed: feitas, studiedHours: feitas * 0.75);
  }

  // ---- CRUD no Firestore (lançam exceção se falhar) ----

  Future<void> adicionar(Task tarefa) async {
    final uid = _uid;
    if (uid == null) throw StateError('Usuário não autenticado.');
    await _colecao.add(tarefa.toMap(uid)).timeout(_limite);
  }

  Future<void> editar(Task tarefa) async {
    await _colecao.doc(tarefa.id).update(tarefa.toUpdateMap()).timeout(_limite);
  }

  Future<void> alternarConclusao(Task tarefa) async {
    await _colecao
        .doc(tarefa.id)
        .update({'completed': !tarefa.completed}).timeout(_limite);
  }
}