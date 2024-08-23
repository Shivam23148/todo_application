import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_application/blocs/TaskBloc/task_bloc.dart';
import 'package:todo_application/blocs/TaskBloc/task_event.dart';
import 'package:todo_application/blocs/TaskBloc/task_state.dart';
import 'package:todo_application/models/task_model.dart';
import 'package:todo_application/services/notification_service.dart';
import 'package:todo_application/services/todo_service.dart';
import 'package:todo_application/utils/date_formating.dart';
import 'package:todo_application/view/AddTaskScreen/add_task_screen.dart';
import 'package:todo_application/view/TaskDetailScreen/task_detail_screen.dart';
import 'package:todo_application/view/TaskEditScreen/task_edit_screen.dart';
import 'package:todo_application/utils/priority_color_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TaskBloc taskBloc;
  @override
  void initState() {
    super.initState();
    taskBloc = TaskBloc(TodoService());
    taskBloc.add(LoadTask());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddTaskScreen(taskBloc: taskBloc)));
                },
                icon: Icon(Icons.add))
          ],
          title: Text(
            "Todos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textScaler: TextScaler.linear(1.2),
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 10),
          child: RefreshIndicator(
            onRefresh: () async {
              taskBloc.add(LoadTask());
            },
            child: BlocBuilder<TaskBloc, TaskState>(
              bloc: taskBloc,
              builder: (context, state) {
                print("Home Screen Task State is $state");
                if (state is TaskLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                  );
                } else if (state is TaskLoaded) {
                  return state.tasks.length <= 0
                      ? Center(
                          child: Text(
                            "No Tasks Added",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.tasks.length,
                          itemBuilder: (context, index) {
                            final task = state.tasks[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                  motion: StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: ((context) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TaskEditScreen(
                                                      taskBloc: taskBloc,
                                                      task: task,
                                                    )));
                                      }),
                                      icon: Icons.edit,
                                      backgroundColor: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      autoClose: true,
                                    ),
                                    SlidableAction(
                                      autoClose: true,
                                      backgroundColor: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                      onPressed: ((context) {
                                        _showDeleteDialog(task.id);
                                      }),
                                      icon: Icons.delete,
                                    )
                                  ]),
                              child: ListTile(
                                subtitle: Text(
                                    "${DateTimeUtils.formatDate(task.dueDate)} at ${DateTimeUtils.formatTime(task.dueDate)}"),
                                title: Text(
                                  task.todoText,
                                  maxLines: 1,
                                  style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                                leading: IconButton(
                                    onPressed: () {
                                      print(
                                          "Before update of isCompleted ${task.isCompleted}");
                                      final bool iscompleted =
                                          !task.isCompleted;
                                      final updatedTask = task.copyWith(
                                          isCompleted: iscompleted);

                                      taskBloc.add(UpdateTask(updatedTask));
                                      print(
                                          "After update of isCompleted ${task.isCompleted}");
                                    },
                                    icon: task.isCompleted
                                        ? Icon(Icons.check_box)
                                        : Icon(Icons.check_box_outline_blank)),
                                trailing: Text(
                                  task.priority
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: getPriorityColor(task.priority)),
                                ),
                              ),
                            );
                          });
                } else if (state is TaskError) {
                  return Center(
                    child: Text(
                      state.error,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      "Unknown State",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  );
                }
              },
            ),
          ),
        ));
  }

  Future<void> _showDeleteDialog(String id) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Delete"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                  )),
              TextButton(
                  onPressed: () {
                    taskBloc.add(DeleteTask(id));
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Delete",
                  ))
            ],
          );
        });
  }
}
