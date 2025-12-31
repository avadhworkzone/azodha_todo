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

  bool _isLoaderVisible = false;

  @override
  void initState() {
    super.initState();

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
    final theme = Theme.of(context);

    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.status == TaskStatus.loading && !_isLoaderVisible) {
          _isLoaderVisible = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status != TaskStatus.loading && _isLoaderVisible) {
          _isLoaderVisible = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddTaskSheet(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'My Tasks',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _debouncer(() {
                      context
                          .read<TaskBloc>()
                          .add(SearchTaskEvent(value));
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Task List
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state.status == TaskStatus.failure) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (state.filteredTasks.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks yet',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(LoadTasks());
                      },
                      child: ListView.separated(
                        padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: state.filteredTasks.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];

                          return Card(
                            elevation: 0.8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.completed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (_) {
                                  context
                                      .read<TaskBloc>()
                                      .add(ToggleTaskEvent(task));
                                },
                              ),
                              title: Text(
                                task.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: task.isSynced
                                  ? null
                                  : const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.sync,
                                        size: 14,
                                        color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text(
                                      'Pending sync',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(context, task),
                              ),
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
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content:
        const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<TaskBloc>().add(DeleteTaskEvent(task));
    }
  }
}
