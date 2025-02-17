import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:nizcorp_machine_task/features/home/controller/home_controller.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: FutureBuilder<TreeNode<String>>(
        future: homeController.fetchTasksFromFirestore(),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
