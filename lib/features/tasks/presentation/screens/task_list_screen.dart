import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/network_utils.dart';
import '../../bloc/task_bloc.dart';
import '../../bloc/task_event.dart';
import '../../bloc/task_state.dart';
import 'add_task_sheet.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late StreamSubscription<List<ConnectivityResult>> sub;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();

    // load cached + remote tasks
    context.read<TaskBloc>().add(LoadTasks());

    sub = Connectivity().onConnectivityChanged.listen((results) {
      if (NetworkUtils.isOnline(results)) {
        context.read<TaskBloc>().add(SyncPendingTasks());
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    sub.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),

      // 🔥 FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(8),
            child:TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search tasks...',
              ),
              onChanged: (value) {
                _debouncer(() {
                  context.read<TaskBloc>().add(SearchTaskEvent(value));
                });
              },
            )

          ),

          // 📋 Task List
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TaskStatus.failure) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Something went wrong'),
                  );
                }

                if (state.filteredTasks.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }

                // 🔄 Pull to Refresh
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TaskBloc>().add(LoadTasks());
                  },
                  child: ListView.builder(
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];

                      return ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) {
                            context
                                .read<TaskBloc>()
                                .add(ToggleTaskEvent(task));
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: task.isSynced
                            ? null
                            : const Text(
                          'Pending sync…',
                          style: TextStyle(color: Colors.orange),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context
                                .read<TaskBloc>()
                                .add(DeleteTaskEvent(task));
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
