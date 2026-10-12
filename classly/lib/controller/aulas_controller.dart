import 'package:flutter/material.dart';
import 'package:classly/model/aula_model.dart';

class AulasController extends ChangeNotifier {
  static const Map<int, String> diasDaSemana = {
    DateTime.monday: 'Segunda-feira',
    DateTime.tuesday: 'Terça-feira',
    DateTime.wednesday: 'Quarta-feira',
    DateTime.thursday: 'Quinta-feira',
    DateTime.friday: 'Sexta-feira',
    DateTime.saturday: 'Sábado',
  };

  final List<Aula> _aulas = [];

  List<Aula> get aulas => List.unmodifiable(_aulas);

  /// Dias que têm pelo menos uma aula, em ordem.
  List<int> get diasComAula {
    final dias = _aulas.map((a) => a.diaSemana).toSet().toList()..sort();
    return dias;
  }

  /// Aulas de um dia, ordenadas pelo horário de início.
  List<Aula> aulasDoDia(int dia) {
    final lista = _aulas.where((a) => a.diaSemana == dia).toList()
      ..sort((a, b) => a.inicioEmMinutos.compareTo(b.inicioEmMinutos));
    return lista;
  }

  // ---- Resumo semanal ----
  int get totalAulas => _aulas.length;
  int get totalDisciplinas =>
      _aulas.map((a) => a.disciplina.trim().toLowerCase()).toSet().length;
  int get diasLetivos => diasComAula.length;
  double get horasPorSemana =>
      _aulas.fold(0.0, (soma, a) => soma + a.duracaoEmHoras);

  // ---- CRUD ----
  void adicionar({
    required String disciplina,
    required int diaSemana,
    required TimeOfDay inicio,
    required TimeOfDay fim,
    required String sala,
  }) {
    _aulas.add(Aula(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      disciplina: disciplina.trim(),
      diaSemana: diaSemana,
      inicio: inicio,
      fim: fim,
      sala: sala.trim(),
    ));
    notifyListeners();
  }

  void editar(Aula atualizada) {
    final i = _aulas.indexWhere((a) => a.id == atualizada.id);
    if (i == -1) return;
    _aulas[i] = atualizada;
    notifyListeners();
  }

  void remover(String id) {
    _aulas.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}