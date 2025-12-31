import 'package:hive/hive.dart';

import '../../models/task_model.dart';

class TaskLocalDataSource {
  final Box<TaskModel> taskBox;
  final Box<TaskModel> pendingBox;

  TaskLocalDataSource(this.taskBox, this.pendingBox);

  List<TaskModel> getTasks() => taskBox.values.toList();

  Future<void> saveTasks(List<TaskModel> tasks) async {
    await taskBox.clear();
    for (var task in tasks) {
      await taskBox.put(task.id, task);
    }
  }

  Future<void> addPending(TaskModel task) async {
    await pendingBox.put(task.id, task);
  }

  List<TaskModel> getPendingTasks() => pendingBox.values.toList();

  Future<void> removePending(String id) async {
    await pendingBox.delete(id);
  }
}
