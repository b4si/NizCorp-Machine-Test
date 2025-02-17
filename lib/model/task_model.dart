import 'package:animated_tree_view/tree_view/tree_node.dart';

class Task {
  final String description;
  final int taskId;
  final String time;
  final String title;
  final List<Task>? subtasks;

  Task({
    required this.description,
    required this.taskId,
    required this.time,
    required this.title,
    this.subtasks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      description: json['description'],
      taskId: json['taskId'],
      time: json['time'],
      title: json['title'],
      subtasks: json['subtasks'] != null
          ? List<Task>.from(json['subtasks'].map((x) => Task.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'taskId': taskId,
      'time': time,
      'title': title,
      'subtasks': subtasks?.map((task) => task.toJson()).toList(),
    };
  }

  TreeNode<String> toTreeNode() {
    final node = TreeNode<String>(data: title);
    node.addAll(subtasks?.map((subtask) => subtask.toTreeNode()) ?? []);
    return node;
  }
}

class TaskDate {
  final String date;
  final List<Task> tasks;

  TaskDate({
    required this.date,
    required this.tasks,
  });

  factory TaskDate.fromJson(Map<String, dynamic> json) {
    return TaskDate(
      date: json['date'],
      tasks: List<Task>.from(json['tasks'].map((x) => Task.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  TreeNode<String> toTreeNode() {
    final node = TreeNode<String>(data: date);
    node.addAll(tasks.map((task) => task.toTreeNode()));
    return node;
  }
}
