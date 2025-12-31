import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'task_event.dart';
import 'task_state.dart';
import '../domain/entities/task.dart';
import '../domain/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc(this.repository) : super(TaskState.initial()) {
    on<LoadTasks>(_loadTasks);
    on<AddTaskEvent>(_addTask);
    on<ToggleTaskEvent>(_toggleTask);
    on<DeleteTaskEvent>(_deleteTask);
    on<SearchTaskEvent>(_searchTask);
    on<SyncPendingTasks>(_syncPending);
  }

  Future<void> _loadTasks(LoadTasks event, Emitter emit) async {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final tasks = await repository.getTasks();
      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: tasks,
        filteredTasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _addTask(AddTaskEvent event, Emitter emit) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      final task = Task(
        id: const Uuid().v4(),
        title: event.title,
        completed: false,
        isSynced: true,
      );

      await repository.addTask(task);

      final updated = [task, ...state.tasks];
      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: updated,
        filteredTasks: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _toggleTask(ToggleTaskEvent event, Emitter emit) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      final updatedTask = event.task.copyWith(
        completed: !event.task.completed,
      );

      await repository.updateTask(updatedTask);

      final updated = state.tasks.map((t) {
        return t.id == updatedTask.id ? updatedTask : t;
      }).toList();

      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: updated,
        filteredTasks: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _deleteTask(DeleteTaskEvent event, Emitter emit) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      await repository.deleteTask(event.task);

      final updated =
      state.tasks.where((t) => t.id != event.task.id).toList();

      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: updated,
        filteredTasks: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _searchTask(SearchTaskEvent event, Emitter emit) {
    final filtered = state.tasks
        .where(
          (t) => t.title.toLowerCase().contains(
        event.query.toLowerCase(),
      ),
    )
        .toList();

    emit(state.copyWith(filteredTasks: filtered));
  }

  Future<void> _syncPending(
      SyncPendingTasks event,
      Emitter emit,
      ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      await repository.syncPendingTasks();
      add(LoadTasks());
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
