import '../domain/entities/task.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}
class AddTaskEvent extends TaskEvent {
  final String title;
  AddTaskEvent(this.title);
}
class ToggleTaskEvent extends TaskEvent {
  final Task task;
  ToggleTaskEvent(this.task);
}
class DeleteTaskEvent extends TaskEvent {
  final Task task;
  DeleteTaskEvent(this.task);
}
class SearchTaskEvent extends TaskEvent {
  final String query;
  SearchTaskEvent(this.query);
}
class SyncPendingTasks extends TaskEvent {}
