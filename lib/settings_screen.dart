import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/settings_model.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const Color background = Color(0xFFF5F2FF);
  static const Color dark = Color(0xFF30234A);
  static const Color purple = Color(0xFF8965F5);

  // ======================================================
  // UPDATE HAPTICS
  // ======================================================

  Future<void> _updateHaptics(bool value) async {
    try {
      await ref.read(settingsProvider.notifier).setHapticsEnabled(value);

      if (!mounted) return;

      if (value) {
        await HapticFeedback.selectionClick();
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not update haptic settings.');
    }
  }

  // ======================================================
  // UPDATE DAILY GOAL
  // ======================================================

  Future<void> _updateDailyGoal(int value) async {
    try {
      await ref.read(settingsProvider.notifier).setDailyGoal(value);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not save your daily goal.');
    }
  }

  // ======================================================
  // CLEAR ALL TASKS
  // ======================================================

  Future<void> _clearTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear all tasks?'),
          content: const Text(
            'This will permanently delete all your tasks. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete all'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(taskProvider.notifier).clearAllTasks();

      if (!mounted) return;

      _showMessage('All tasks have been cleared.');
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not clear tasks. Please try again.');
    }
  }

  // ======================================================
  // SNACKBAR
  // ======================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: settingsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: purple)),
              error: (error, stackTrace) {
                return _buildErrorState();
              },
              data: (settings) {
                return _buildSettingsContent(settings);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // ERROR STATE
  // ======================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load settings',
              style: TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your settings and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(settingsProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(backgroundColor: purple),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // SETTINGS CONTENT
  // ======================================================

  Widget _buildSettingsContent(SettingsModel settings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 22.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            22,
            horizontalPadding,
            110,
          ),
          children: [
            const Text(
              'Settings ⚙️',
              style: TextStyle(
                color: dark,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Make TaskSphere work your way.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // APP CARD
            _buildAppCard(),

            const SizedBox(height: 27),

            // PRODUCTIVITY
            _sectionTitle('PRODUCTIVITY'),

            _settingsCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _leadingIcon(
                      Icons.flag_rounded,
                      const Color(0xFF8C68EC),
                    ),
                    title: const Text(
                      'Daily task goal',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${settings.dailyGoal} tasks per day'),
                  ),

                  Slider(
                    value: settings.dailyGoal.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: purple,
                    onChanged: (value) {
                      _updateDailyGoal(value.round());
                    },
                  ),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 task', style: TextStyle(fontSize: 11)),
                      Text('20 tasks', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // PREFERENCES
            _sectionTitle('PREFERENCES'),

            _settingsCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: _leadingIcon(
                  Icons.vibration_rounded,
                  const Color(0xFF32B99A),
                ),
                title: const Text(
                  'Haptic feedback',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Vibration when changing app tabs'),
                value: settings.hapticsEnabled,
                activeThumbColor: purple,
                onChanged: _updateHaptics,
              ),
            ),

            const SizedBox(height: 22),

            // DATA & STORAGE
            _sectionTitle('DATA & STORAGE'),

            _settingsCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _leadingIcon(
                  Icons.delete_sweep_rounded,
                  Colors.redAccent,
                ),
                title: const Text(
                  'Clear all tasks',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text('Permanently remove saved tasks'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                onTap: _clearTasks,
              ),
            ),

            const SizedBox(height: 22),

            // ABOUT
            _sectionTitle('ABOUT'),

            _settingsCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _leadingIcon(
                      Icons.info_outline_rounded,
                      const Color(0xFF3999D8),
                    ),
                    title: const Text(
                      'About TaskSphere',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'A colorful space for your daily goals',
                    ),
                    trailing: const Text(
                      'v1.0.0',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.favorite_rounded,
                      color: Colors.pinkAccent,
                    ),
                    title: Text(
                      'Made with Flutter',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('Keep learning. Keep building.'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                'TASKSPHERE • YOUR PRODUCTIVITY UNIVERSE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // APP CARD
  // ======================================================

  Widget _buildAppCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B72FF), Color(0xFF6841D9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8056E9).withValues(alpha: 0.23),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white24,
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskSphere',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Build habits. Complete goals. Level up.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD76A), size: 27),
        ],
      ),
    );
  }

  // ======================================================
  // REUSABLE WIDGETS
  // ======================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 3),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF806DA5),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _leadingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
