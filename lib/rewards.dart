import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_application/models/rewards_model.dart';

import 'models/rewards_model.dart';
import 'providers/rewards_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const Color background = Color(0xFFF5F2FF);
  static const Color dark = Color(0xFF30234A);
  static const Color purple = Color(0xFF8055E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RewardsProvider automatically listens to TaskProvider.
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 380
                    ? 16.0
                    : 22.0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    22,
                    horizontalPadding,
                    30,
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),

                    _LevelCard(
                      xp: rewards.totalXp,
                      level: rewards.currentLevel,
                      levelXp: rewards.currentLevelXp,
                      progress: rewards.levelProgress,
                    ),

                    const SizedBox(height: 22),

                    _buildStats(
                      completed: rewards.completedTasks,
                      pending: rewards.pendingTasks,
                      total: rewards.totalTasks,
                    ),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      title: 'Your Achievements',
                      trailing:
                          '${rewards.unlockedBadges} / ${rewards.totalBadges} unlocked',
                    ),

                    const SizedBox(height: 14),

                    ...rewards.badges.map((badge) => _BadgeTile(badge: badge)),

                    const SizedBox(height: 18),

                    _NextRewardCard(
                      completed: rewards.completedTasks,
                      xp: rewards.totalXp,
                      nextBadge: rewards.nextBadge,
                      remaining: rewards.tasksUntilNextBadge,
                    ),

                    const SizedBox(height: 18),

                    _MotivationCard(
                      completed: rewards.completedTasks,
                      total: rewards.totalTasks,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Rewards',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: dark,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Every completed task brings you forward.',
                style: TextStyle(color: Color(0xFF8A8299), fontSize: 12),
              ),
            ],
          ),
        ),
        _FloatingTrophy(),
      ],
    );
  }

  Widget _buildStats({
    required int completed,
    required int pending,
    required int total,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Completed',
                value: '$completed',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF35B987),
                compact: compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Pending',
                value: '$pending',
                icon: Icons.pending_actions_rounded,
                color: const Color(0xFFFF9B45),
                compact: compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Total',
                value: '$total',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF8D69EC),
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: dark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8DFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF7045C8),
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// LEVEL CARD
// ======================================================

class _LevelCard extends StatelessWidget {
  final int xp;
  final int level;
  final int levelXp;
  final double progress;

  const _LevelCard({
    required this.xp,
    required this.level,
    required this.levelXp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAA83FF), Color(0xFF8055E8), Color(0xFF5933C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8056E9).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -35,
            child: Icon(
              Icons.stars_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'YOUR CURRENT LEVEL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFFD76A),
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  'Level $level',
                  key: ValueKey(level),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$xp XP earned',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 23),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(levelXp),
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFFD76A),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$levelXp / ${RewardsModel.xpPerLevel} XP to next level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_upward_rounded,
                    color: Color(0xFFFFD76A),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// STAT CARD
// ======================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: compact ? 20 : 23),
          const SizedBox(height: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              value,
              key: ValueKey(value),
              style: TextStyle(
                color: const Color(0xFF30234A),
                fontSize: compact ? 21 : 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// BADGE TILE
// ======================================================

class _BadgeTile extends StatelessWidget {
  final RewardBadge badge;

  const _BadgeTile({required this.badge});

  IconData get badgeIcon {
    switch (badge.id) {
      case 'first_step':
        return Icons.flag_rounded;
      case 'task_hunter':
        return Icons.local_fire_department_rounded;
      case 'productivity_master':
        return Icons.military_tech_rounded;
      case 'legend':
        return Icons.diamond_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  Color get badgeColor {
    switch (badge.id) {
      case 'first_step':
        return const Color(0xFF35B987);
      case 'task_hunter':
        return const Color(0xFFFF884D);
      case 'productivity_master':
        return const Color(0xFFFFB938);
      case 'legend':
        return const Color(0xFF6E8CFF);
      default:
        return const Color(0xFF8055E8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final color = badgeColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.30)
              : Colors.grey.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? color.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.13)
                  : const Color(0xFFF2F0F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              badgeIcon,
              color: unlocked ? color : Colors.grey.shade400,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFF30234A)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge.target} ${badge.target == 1 ? 'task' : 'tasks'}',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
            color: unlocked ? color : Colors.grey.shade400,
            size: 23,
          ),
        ],
      ),
    );
  }
}

// ======================================================
// NEXT REWARD CARD
// ======================================================

class _NextRewardCard extends StatelessWidget {
  final int completed;
  final int xp;
  final RewardBadge? nextBadge;
  final int remaining;

  const _NextRewardCard({
    required this.completed,
    required this.xp,
    required this.nextBadge,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final allUnlocked = nextBadge == null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1D8), Color(0xFFFFE4BC)],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFFFD89B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFFE99125),
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Milestone',
                  style: TextStyle(
                    color: Color(0xFF9B5D15),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  allUnlocked
                      ? 'All current badges unlocked!'
                      : '$remaining more ${remaining == 1 ? 'task' : 'tasks'} to unlock ${nextBadge!.title}',
                  style: const TextStyle(
                    color: Color(0xFF9B6A32),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$xp XP collected',
                  style: const TextStyle(
                    color: Color(0xFFB4772E),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MOTIVATION CARD
// ======================================================

class _MotivationCard extends StatelessWidget {
  final int completed;
  final int total;

  const _MotivationCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final message = total == 0
        ? 'Your journey starts with one task. Create your first task!'
        : completed == total
        ? 'Amazing! You have completed every task. Keep growing!'
        : 'You are making progress. Every small step counts!';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8F3),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFD2F0E5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF35B987),
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF287B62),
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FLOATING TROPHY
// ======================================================

class _FloatingTrophy extends StatefulWidget {
  const _FloatingTrophy();

  @override
  State<_FloatingTrophy> createState() => _FloatingTrophyState();
}

class _FloatingTrophyState extends State<_FloatingTrophy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = math.sin(_controller.value * math.pi) * 5;

        return Transform.translate(offset: Offset(0, -offset), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD76A), Color(0xFFFF9C42)],
          ),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA33E).withValues(alpha: 0.3),
              blurRadius: 13,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          color: Colors.white,
          size: 29,
        ),
      ),
    );
  }
}
