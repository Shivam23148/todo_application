import 'package:hive/hive.dart';
import 'package:todo_application/models/task_model.dart';

class TodoService {
  late Box<Task> taskBox;
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isAdapterRegistered(TaskPriorityAdapter().typeId)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    taskBox = await Hive.openBox<Task>('tasks');
  }

  List<Task> getTasks() {
    return taskBox.values.toList();
  }

  Future<void> addTask(Task task) async {
    await taskBox.add(task);
  }

  Future<void> updateTask(Task task) async {
    final taskToUpdate =
        taskBox.values.firstWhere((value) => value.id == task.id);
    taskToUpdate.todoText = task.todoText;
    taskToUpdate.dueDate = task.dueDate;
    taskToUpdate.priority = task.priority;
    taskToUpdate.isCompleted = task.isCompleted;

    taskToUpdate.save();
  }

  Future<void> deleteTask(String id) async {
    try {
      final taskToDelete = taskBox.values.firstWhere((value) => value.id == id);
      taskToDelete.delete();
    } catch (e) {
      print("The error in the deletin the task is : $e");
    }
  }
}
