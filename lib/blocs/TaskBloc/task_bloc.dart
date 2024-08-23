import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_application/blocs/TaskBloc/task_event.dart';
import 'package:todo_application/blocs/TaskBloc/task_state.dart';
import 'package:todo_application/services/todo_service.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TodoService todoService;

  TaskBloc(this.todoService) : super(TaskLoading()) {
    on<LoadTask>(_onLoadTask);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTask(LoadTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await todoService.init();
      final tasks = todoService.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to load tasks"));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await todoService.addTask(event.task);
      final tasks = todoService.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to add task"));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await todoService.updateTask(event.updatedTask);
      final tasks = todoService.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      print("Error is updating task is: ${e}");
      emit(TaskError("Failed to update task"));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await todoService.deleteTask(event.id);
      final tasks = todoService.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to delete task"));
    }
  }
}
