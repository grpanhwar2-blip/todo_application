import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_provider.dart';

class DashboardStats {
  final int totalTasks;
  final int completedTasks;
  final double progress;

  const DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
  });
}

final dashboardProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(taskProvider);

  final total = tasks.length;

  final completed = tasks.where((task) => task.isCompleted).length;

  final progress = total == 0 ? 0.0 : completed / total;

  return DashboardStats(
    totalTasks: total,
    completedTasks: completed,
    progress: progress,
  );
});
