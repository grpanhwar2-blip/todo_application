class RewardBadge {
  final String id;
  final String title;
  final String description;
  final int target;
  final bool isUnlocked;

  const RewardBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.isUnlocked = false,
  });

  RewardBadge copyWith({bool? isUnlocked}) {
    return RewardBadge(
      id: id,
      title: title,
      description: description,
      target: target,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class RewardsModel {
  static const int xpPerTask = 50;
  static const int xpPerLevel = 250;

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int totalXp;
  final int currentLevel;
  final int currentLevelXp;
  final double levelProgress;
  final List<RewardBadge> badges;

  const RewardsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.totalXp,
    required this.currentLevel,
    required this.currentLevelXp,
    required this.levelProgress,
    required this.badges,
  });

  factory RewardsModel.fromTaskCounts({
    required int totalTasks,
    required int completedTasks,
  }) {
    final safeCompleted = completedTasks.clamp(0, totalTasks);
    final pending = totalTasks - safeCompleted;

    final xp = safeCompleted * xpPerTask;
    final level = (xp ~/ xpPerLevel) + 1;
    final levelXp = xp % xpPerLevel;

    final badgeDefinitions = <RewardBadge>[
      const RewardBadge(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete your first task',
        target: 1,
      ),
      const RewardBadge(
        id: 'task_hunter',
        title: 'Task Hunter',
        description: 'Complete 5 tasks',
        target: 5,
      ),
      const RewardBadge(
        id: 'productivity_master',
        title: 'Productivity Master',
        description: 'Complete 20 tasks',
        target: 20,
      ),
      const RewardBadge(
        id: 'legend',
        title: 'Legend',
        description: 'Complete 50 tasks',
        target: 50,
      ),
    ];

    final updatedBadges = badgeDefinitions
        .map((badge) {
          return badge.copyWith(isUnlocked: safeCompleted >= badge.target);
        })
        .toList(growable: false);

    return RewardsModel(
      totalTasks: totalTasks,
      completedTasks: safeCompleted,
      pendingTasks: pending,
      totalXp: xp,
      currentLevel: level,
      currentLevelXp: levelXp,
      levelProgress: levelXp / xpPerLevel,
      badges: List.unmodifiable(updatedBadges),
    );
  }

  int get unlockedBadges => badges.where((badge) => badge.isUnlocked).length;

  int get totalBadges => badges.length;

  RewardBadge? get nextBadge {
    for (final badge in badges) {
      if (!badge.isUnlocked) return badge;
    }
    return null;
  }

  int get tasksUntilNextBadge {
    final badge = nextBadge;
    if (badge == null) return 0;

    return (badge.target - completedTasks).clamp(0, badge.target);
  }
}
