import 'package:flutter/material.dart';
import 'package:nizcorp_machine_task/core/common_methods/notification_permission_method.dart';
import 'package:nizcorp_machine_task/features/home/controller/home_controller.dart';
import 'package:nizcorp_machine_task/features/home/presentation/pages/task_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

import '../../../../model/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController homeController;

  @override
  void initState() {
    homeController = context.read<HomeController>();
    requestNotificationPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Task Tree'),
        ),
        body: FutureBuilder<TreeNode<String>>(
          future: homeController.fetchTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.children.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            } else {
              return TreeView.simple(
                tree: snapshot.data!,
                expansionBehavior: ExpansionBehavior.collapseOthers,
                builder: (context, node) {
                  return ListTile(
                    title: Text(node.data ?? ''),
                    subtitle: node.level == 1
                        ? Text('Date: ${node.data}')
                        : Text('Task: ${node.data}'),
                    leading: IconButton(
                      onPressed: () async {
                        if (node.level != 1) {
                          final task = Task(
                            description: 'Sample Description',
                            taskId: 1,
                            time: 'Sample Time',
                            title: node.data ?? 'Sample Title',
                            subtasks: [],
                          );
                          await homeController.addTaskToFirestore(task);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Task added to Firestore')),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_circle),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskListScreen(),
                ));
          },
          child: const Icon(Icons.list),
        ));
  }
}
