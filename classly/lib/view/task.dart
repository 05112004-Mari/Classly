enum Priority { low, medium, high }

class Task {
  final int id;
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
}