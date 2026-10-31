import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rewards_model.dart';
import 'task_provider.dart';

final rewardsProvider = Provider<RewardsModel>((ref) {
  final tasks = ref.watch(taskProvider);

  final completedTasks = tasks.where((task) => task.isCompleted).length;

  return RewardsModel.fromTaskCounts(
    totalTasks: tasks.length,
    completedTasks: completedTasks,
  );
});
