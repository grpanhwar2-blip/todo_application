import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_application/task_details.dart';

import 'models/task_model.dart';
import 'providers/task_provider.dart';
import 'providers/dashboard_provider.dart';
import 'add_task.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedCategory = 0;

  final List<String> categories = ['All', 'Work', 'Personal', 'Study'];

  static const Color primaryColor = Color(0xFF8965F5);
  static const Color darkColor = Color(0xFF30234A);
  static const Color backgroundColor = Color(0xFFF5F2FF);

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final stats = ref.watch(dashboardProvider);

    final filteredTasks = selectedCategory == 0
        ? tasks
        : tasks.where((task) {
            return task.category == TaskCategory.values[selectedCategory - 1];
          }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 700 ? 32 : 20,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 28),

                      _buildProgressCard(stats),

                      const SizedBox(height: 30),

                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildCategoryFilters(),

                      const SizedBox(height: 28),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Your Tasks',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              ),
                            ),
                          ),
                          Text(
                            '${filteredTasks.length} Tasks',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      if (filteredTasks.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredTasks.map((task) => _buildTask(task)),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton.extended(
          onPressed: _openAddTask,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Task',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()} 👋',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              const Text(
                'Let’s be productive!',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFFFC857),
          child: Icon(Icons.person, color: darkColor, size: 30),
        ),
      ],
    );
  }

  // PROGRESS CARD
  Widget _buildProgressCard(dynamic stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8965F5), Color(0xFFB18CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Daily Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep going! You are doing great.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: stats.progress,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD45C)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                '${(stats.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${stats.completedTasks} of ${stats.totalTasks} tasks completed',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // CATEGORY FILTERS
  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = selectedCategory == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedCategory = index;
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : darkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }

  // TASK CARD
  Widget _buildTask(TaskModel task) {
    final color = _getCategoryColor(task.category);
    final icon = _getCategoryIcon(task.category);

    final formattedTime = TimeOfDay.fromDateTime(task.dueAt).format(context);

    final formattedDate =
        '${task.dueAt.day.toString().padLeft(2, '0')}/'
        '${task.dueAt.month.toString().padLeft(2, '0')}/'
        '${task.dueAt.year}';

    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),

          // TAP CARD TO OPEN DETAILS
          onTap: () => _openTaskDetails(task),

          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // CATEGORY ICON
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: darkColor),
                ),

                const SizedBox(width: 12),

                // TASK INFORMATION
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: darkColor,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      if (task.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],

                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 8,
                        runSpacing: 5,
                        children: [
                          _smallDetail(
                            Icons.calendar_today_outlined,
                            formattedDate,
                          ),
                          _smallDetail(Icons.access_time, formattedTime),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 7,
                        runSpacing: 5,
                        children: [
                          if (isOverdue) _statusBadge('Overdue', Colors.red),
                          if (task.isCompleted)
                            _statusBadge('Completed', Colors.green),
                          if (!task.isCompleted && !isOverdue)
                            _statusBadge('Pending', Colors.orange),
                          _priorityBadge(task.priority),
                        ],
                      ),

                      const SizedBox(height: 5),

                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View details',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // COMPLETE BUTTON
                IconButton(
                  tooltip: task.isCompleted
                      ? 'Mark as pending'
                      : 'Mark as completed',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _toggleTask(task),
                  icon: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: primaryColor,
                    size: 26,
                  ),
                ),

                // EDIT / DELETE MENU
                PopupMenuButton<String>(
                  tooltip: 'Task options',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editTask(task);
                    } else if (value == 'delete') {
                      _confirmDelete(task);
                    } else if (value == 'details') {
                      _openTaskDetails(task);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 19),
                          SizedBox(width: 10),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),
                          SizedBox(width: 10),
                          Text('Edit Task'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete Task',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SMALL DATE / TIME DETAIL
  Widget _smallDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  // STATUS BADGE
  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // PRIORITY BADGE
  Widget _priorityBadge(TaskPriority priority) {
    final Color color;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.blue;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.high:
        color = Colors.deepOrange;
        break;
      case TaskPriority.urgent:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // OPEN TASK DETAILS
  void _openTaskDetails(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
  }

  // OPEN ADD TASK
  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }

  // EDIT TASK
  Future<void> _editTask(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
    );
  }

  // TOGGLE COMPLETION
  Future<void> _toggleTask(TaskModel task) async {
    try {
      await ref.read(taskProvider.notifier).toggleTask(task.id);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not update task status.');
    }
  }

  // DELETE CONFIRMATION
  Future<void> _confirmDelete(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Delete Task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"? '
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await ref.read(taskProvider.notifier).deleteTask(task.id);

      if (!mounted) return;

      _showMessage('Task deleted successfully.');
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not save the deletion. Please try again.');
    }
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt, size: 45, color: primaryColor),
          SizedBox(height: 10),
          Text(
            'No tasks found!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add some tasks to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // SNACKBAR
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // GREETING
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // CATEGORY COLORS
  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFFFFE2D5);
      case TaskCategory.personal:
        return const Color(0xFFD2F5E9);
      case TaskCategory.study:
        return const Color(0xFFDCD5FF);
    }
  }

  // CATEGORY ICONS
  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline;
      case TaskCategory.personal:
        return Icons.person_outline;
      case TaskCategory.study:
        return Icons.menu_book;
    }
  }
}
