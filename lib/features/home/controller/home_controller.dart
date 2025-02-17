import 'dart:convert';

import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nizcorp_machine_task/features/home/services/home_services.dart';
import 'package:nizcorp_machine_task/main.dart';
import 'package:nizcorp_machine_task/model/task_model.dart';

class HomeController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TreeNode<String>> fetchTasksFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();

      final rootNode = TreeNode<String>(data: 'Tasks');

      for (final doc in querySnapshot.docs) {
        final taskData = doc.data();
        final task = Task(
          description: taskData['description'],
          taskId: taskData['taskId'],
          time: taskData['time'],
          title: taskData['title'],
          subtasks: taskData['subtasks'] != null
              ? List<Task>.from(
                  taskData['subtasks'].map((x) => Task.fromJson(x)))
              : null,
        );

        final taskNode = task.toTreeNode();
        rootNode.add(taskNode);
      }

      return rootNode;
    } catch (e) {
      throw Exception('Failed to fetch tasks from Firestore: $e');
    }
  }

  Future<void> scheduleNotification(String taskTitle) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Task Added',
      'Task "$taskTitle" has been added.',
      platformChannelSpecifics,
    );
  }

  Future<void> addTaskToFirestore(Task task) async {
    try {
      await _firestore.collection('tasks').add({
        'description': task.description,
        'taskId': task.taskId,
        'time': task.time,
        'title': task.title,
        'subtasks': task.subtasks?.map((subtask) => subtask.toJson()).toList(),
      });
      scheduleNotification(task.title);
    } catch (e) {
      throw Exception('Failed to add task to Firestore: $e');
    }
  }

  Future<TreeNode<String>> fetchTasks() async {
    try {
      final response = await HomeServices().getTask();

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);

        final rootNode = TreeNode<String>(data: 'Tasks');
        for (var taskDate in data) {
          final taskDateNode = TaskDate.fromJson(taskDate).toTreeNode();
          rootNode.add(taskDateNode);
        }

        return rootNode;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load tasks: ${e.message}');
    }
  }
}
