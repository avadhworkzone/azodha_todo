import 'package:dio/dio.dart';
import '../../models/task_model.dart';

class TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSource(this.dio);

  Future<List<TaskModel>> fetchTasks() async {
    print('[API] GET /todos');
    final res = await dio.get('/todos');
    print('[API] RESPONSE ${res.statusCode}');
    return (res.data as List)
        .map((e) => TaskModel.fromJson(e))
        .toList();
  }

  Future<void> addTask(TaskModel task) async {
    print('[API] POST /todos BODY=${task.toJson()}');
    final res = await dio.post('/todos', data: task.toJson());
    print('[API] RESPONSE ${res.statusCode} ${res.data}');
  }

  Future<void> updateTask(TaskModel task) async {
    print('[API] PATCH /todos/${task.id} BODY=${task.toJson()}');
    final res =
    await dio.patch('/todos/${task.id}', data: task.toJson());
    print('[API] RESPONSE ${res.statusCode} ${res.data}');
  }

  Future<void> deleteTask(String id) async {
    print('[API] DELETE /todos/$id');
    final res = await dio.delete('/todos/$id');
    print('[API] RESPONSE ${res.statusCode}');
  }
}
