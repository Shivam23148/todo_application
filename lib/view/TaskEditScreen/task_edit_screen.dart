import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_application/blocs/TaskBloc/task_bloc.dart';
import 'package:todo_application/blocs/TaskBloc/task_event.dart';
import 'package:todo_application/models/task_model.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;
  final TaskBloc taskBloc;

  TaskEditScreen({super.key, required this.task, required this.taskBloc});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController taskText;
  late DateTime _selectedDueDateTime;
  late TaskPriority _selectedPriority;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    taskText = TextEditingController(text: widget.task.todoText);
    _selectedDueDateTime = widget.task.dueDate;
    _selectedPriority = widget.task.priority;

    // Add listener to detect changes in the text field
    taskText.addListener(() {
      setState(() {
        _hasUnsavedChanges = taskText.text.isNotEmpty &&
            (taskText.text != widget.task.todoText ||
                _selectedDueDateTime != widget.task.dueDate ||
                _selectedPriority != widget.task.priority);
      });
    });
  }

  @override
  void dispose() {
    taskText.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text('Do you want to save the changes before leaving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Save'),
            ),
          ],
        ),
      );

      if (shouldSave ?? false) {
        _saveTask();
      }
    }
    return true;
  }

  void _saveTask() {
    if (taskText.text.isNotEmpty) {
      final updatedTask = Task(
        id: widget.task.id,
        todoText: taskText.text,
        priority: _selectedPriority,
        dueDate: _selectedDueDateTime,
      );
      widget.taskBloc.add(UpdateTask(updatedTask));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task description.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDueDateTime);
    String formattedTime = DateFormat('hh:mm a').format(_selectedDueDateTime);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Task",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("What is to be done?"),
              SizedBox(height: 5),
              TextField(
                controller: taskText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("Due Date"),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "$formattedDate at $formattedTime",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      size: MediaQuery.of(context).size.height * 0.025,
                    ),
                  ),
                  IconButton(
                    onPressed: _selectTime,
                    icon: Icon(
                      Icons.access_time_rounded,
                      size: MediaQuery.of(context).size.height * 0.025,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                onChanged: (TaskPriority? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                    _hasUnsavedChanges = true;
                  });
                },
                items: TaskPriority.values.map((TaskPriority priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(_getPriorityLabel(priority)),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveTask,
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDueDateTime) {
      setState(() {
        _selectedDueDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDueDateTime.hour,
          _selectedDueDateTime.minute,
        );
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDateTime),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDateTime = DateTime(
          _selectedDueDateTime.year,
          _selectedDueDateTime.month,
          _selectedDueDateTime.day,
          picked.hour,
          picked.minute,
        );
        _hasUnsavedChanges = true;
      });
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
      default:
        return 'Unknown Priority';
    }
  }
}
