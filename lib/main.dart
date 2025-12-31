import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/dio_logger_interceptor.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/tasks/data/datasources/local/task_local_ds.dart';
import 'features/tasks/data/datasources/remote/task_remote_ds.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/domain/repositories/task_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());

  final taskBox = await Hive.openBox<TaskModel>('tasks');
  final pendingBox = await Hive.openBox<TaskModel>('pending_tasks');

  final dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  dio.interceptors.add(DioLoggerInterceptor());

  final repository = TaskRepositoryImpl(
    remote: TaskRemoteDataSource(dio),
    local: TaskLocalDataSource(taskBox, pendingBox),
    connectivity: Connectivity(),
  );
  runApp(
    BlocProvider<TaskBloc>(
      create: (_) => TaskBloc(repository),
      child: const MyApp(),
    ),
  );
}
