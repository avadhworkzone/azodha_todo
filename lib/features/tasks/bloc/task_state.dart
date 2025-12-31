import '../domain/entities/task.dart';

enum TaskStatus { loading, success, failure }

class TaskState {
  final TaskStatus status;
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final String? errorMessage;

  TaskState({
    required this.status,
    required this.tasks,
    required this.filteredTasks,
    this.errorMessage,
  });

  factory TaskState.initial() => TaskState(
    status: TaskStatus.loading,
    tasks: [],
    filteredTasks: [],
  );

  TaskState copyWith({
    TaskStatus? status,
    List<Task>? tasks,
    List<Task>? filteredTasks,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      errorMessage: errorMessage,
    );
  }
}
