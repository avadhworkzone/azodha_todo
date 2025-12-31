import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  bool isSynced;

  @HiveField(4)
  String? pendingAction;

  TaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.isSynced,
    this.pendingAction,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      completed: (json['completed'] ?? false) == true,
      isSynced: true,
      pendingAction: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  // Mapping
  Task toEntity() => Task(
    id: id,
    title: title,
    completed: completed,
    isSynced: isSynced,
    pendingAction: pendingAction,
  );

  static TaskModel fromEntity(Task t) => TaskModel(
    id: t.id,
    title: t.title,
    completed: t.completed,
    isSynced: t.isSynced,
    pendingAction: t.pendingAction,
  );
}

/// ✅ MANUAL Hive Adapter (NO build_runner needed)
class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      completed: fields[2] as bool,
      isSynced: fields[3] as bool,
      pendingAction: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.pendingAction);
  }
}
