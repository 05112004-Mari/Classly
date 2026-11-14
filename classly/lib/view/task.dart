import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class Task {
  final String id; // id do documento no Firestore ('' enquanto não foi salva)
  final String title;
  final String description;
  final Priority priority;
  final String dueDate;
  final String? dueTime; // opcional
  final String subject;
  final bool completed;
  final bool isExam;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.dueTime,
    required this.subject,
    this.completed = false,
    this.isExam = false,
  });

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    String? dueDate,
    String? dueTime,
    String? subject,
    bool? completed,
    bool? isExam,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      subject: subject ?? this.subject,
      completed: completed ?? this.completed,
      isExam: isExam ?? this.isExam,
    );
  }

  // ---- Firestore ----

  /// Converte um documento da coleção "tarefas" em [Task].
  factory Task.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final hora = (d['dueTime'] ?? '') as String;
    return Task(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      priority: Priority.values.firstWhere(
        (p) => p.name == d['priority'],
        orElse: () => Priority.medium,
      ),
      dueDate: (d['dueDate'] ?? '') as String,
      dueTime: hora.isEmpty ? null : hora,
      subject: (d['subject'] ?? '') as String,
      completed: (d['completed'] ?? false) as bool,
      isExam: (d['isExam'] ?? false) as bool,
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
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate,
      'dueTime': dueTime ?? '',
      'subject': subject,
      'completed': completed,
      'isExam': isExam,
    };
  }
}