import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/local/task_local_ds.dart';
import '../../data/datasources/remote/task_remote_ds.dart';
import '../../data/models/task_model.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  final Connectivity connectivity;

  TaskRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  Future<bool> _isOnline() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Future<List<Task>> getTasks() async {
    print('[Repo] getTasks');
    final cached = local.getTasks();

    if (await _isOnline()) {
      try {
        final remoteTasks = await remote.fetchTasks();
        await local.saveTasks(remoteTasks);
        return remoteTasks.map((e) => e.toEntity()).toList();
      } catch (e) {
        print('[Repo] GET failed → using cache');
        return cached.map((e) => e.toEntity()).toList();
      }
    }
    print('[Repo] Offline → using cache');
    return cached.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    final online = await _isOnline();

    print('[Repo] ADD online=$online id=${task.id}');

    if (online) {
      await remote.addTask(model);
      model.isSynced = true;
      model.pendingAction = null;
    } else {
      model.isSynced = false;
      model.pendingAction = 'add';
      await local.addPending(model);
    }

    // 🔥 FIX: always save locally
    await local.taskBox.put(model.id, model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    final online = await _isOnline();

    print('[Repo] UPDATE online=$online id=${task.id}');

    if (online) {
      await remote.updateTask(model);
      model.isSynced = true;
      model.pendingAction = null;
    } else {
      model.isSynced = false;
      model.pendingAction = 'update';
      await local.addPending(model);
    }

    await local.taskBox.put(model.id, model);
  }

  @override
  Future<void> deleteTask(Task task) async {
    final online = await _isOnline();

    print('[Repo] DELETE online=$online id=${task.id}');

    if (online) {
      await remote.deleteTask(task.id);
    } else {
      final model = TaskModel.fromEntity(task)
        ..pendingAction = 'delete'
        ..isSynced = false;
      await local.addPending(model);
    }

    await local.taskBox.delete(task.id);
  }

  @override
  Future<void> syncPendingTasks() async {
    if (!await _isOnline()) return;

    final pending = local.getPendingTasks();
    print('[Repo] SYNC pending=${pending.length}');

    for (final task in pending) {
      try {
        print('[Repo] SYNC id=${task.id} action=${task.pendingAction}');

        if (task.pendingAction == 'add') {
          await remote.addTask(task);
        } else if (task.pendingAction == 'update') {
          await remote.updateTask(task);
        } else if (task.pendingAction == 'delete') {
          await remote.deleteTask(task.id);
          await local.taskBox.delete(task.id);
          await local.removePending(task.id);
          continue;
        }

        task
          ..isSynced = true
          ..pendingAction = null;

        await local.taskBox.put(task.id, task);
        await local.removePending(task.id);
      } catch (e) {
        print('[Repo] SYNC FAILED id=${task.id}');
      }
    }
  }
}
