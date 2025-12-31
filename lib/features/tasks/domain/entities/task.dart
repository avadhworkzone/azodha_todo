class Task {
  final String id;
  final String title;
  final bool completed;

  /// For offline strategy
  final bool isSynced; // true = server synced, false = pending
  final String? pendingAction; // 'add' | 'update' | 'delete' | null

  const Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.isSynced,
    this.pendingAction,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    bool? isSynced,
    String? pendingAction,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isSynced: isSynced ?? this.isSynced,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }
}
