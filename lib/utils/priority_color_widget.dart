import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo_application/models/task_model.dart';

Color getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red;
    case TaskPriority.medium:
      return Colors.orange;
    case TaskPriority.low:
      return Colors.green;
    default:
      return Colors.black;
  }
}
