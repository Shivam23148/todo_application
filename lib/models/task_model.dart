import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String todoText;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  TaskPriority priority;

  @HiveField(4)
  DateTime dueDate;

  Task({
    required this.id,
    required this.todoText,
    this.isCompleted = false,
    required this.priority,
    required this.dueDate,
  });
  Task copyWith({
    String? id,
    String? todoText,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      todoText: todoText ?? this.todoText,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}
