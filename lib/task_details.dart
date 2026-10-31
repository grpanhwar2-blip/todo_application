import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/task_model.dart';
import 'providers/task_provider.dart';
import 'add_task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  static const Color primaryColor = Color(0xFF8965F5);
  static const Color darkColor = Color(0xFF30234A);
  static const Color backgroundColor = Color(0xFFF5F2FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    TaskModel? currentTask;
    for (final item in tasks) {
      if (item.id == task.id) {
        currentTask = item;
        break;
      }
    }

    if (currentTask == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: const Text('Task Details', style: TextStyle(color: darkColor)),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This task is no longer available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: darkColor),
            ),
          ),
        ),
      );
    }

    final current = currentTask;
    final isOverdue = current.isOverdue;

    final status = current.isCompleted
        ? 'Completed'
        : isOverdue
        ? 'Overdue'
        : 'Pending';

    final statusColor = current.isCompleted
        ? Colors.green
        : isOverdue
        ? Colors.red
        : Colors.orange;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: darkColor),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(color: darkColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: darkColor),
            onSelected: (value) {
              if (value == 'edit') {
                _editTask(context, current);
              } else if (value == 'delete') {
                _deleteTask(context, ref, current);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Edit Task'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 700 ? 32 : 18,
                vertical: 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroCard(current, status, statusColor),
                      const SizedBox(height: 24),

                      _sectionTitle('Task Information'),
                      const SizedBox(height: 12),
                      _informationCard(current, status, statusColor),

                      const SizedBox(height: 24),
                      _sectionTitle('Description'),
                      const SizedBox(height: 12),
                      _descriptionCard(current),

                      const SizedBox(height: 24),
                      _sectionTitle('Priority'),
                      const SizedBox(height: 12),
                      _priorityCard(context, ref, current),

                      const SizedBox(height: 24),
                      _sectionTitle('Checklist'),
                      const SizedBox(height: 12),
                      _checklistCard(context, ref, current),

                      const SizedBox(height: 24),
                      _sectionTitle('Tags'),
                      const SizedBox(height: 12),
                      _tagsCard(context, ref, current),

                      const SizedBox(height: 24),
                      _sectionTitle('Personal Notes'),
                      const SizedBox(height: 12),
                      _notesCard(context, ref, current),

                      const SizedBox(height: 24),
                      _sectionTitle('Task Timeline'),
                      const SizedBox(height: 12),
                      _timelineCard(current),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _runAction(
                            context,
                            () => ref
                                .read(taskProvider.notifier)
                                .toggleTask(current.id),
                            'Could not update task status.',
                          ),
                          icon: Icon(
                            current.isCompleted
                                ? Icons.refresh
                                : Icons.check_circle_outline,
                          ),
                          label: Text(
                            current.isCompleted
                                ? 'Mark as Pending'
                                : 'Mark as Completed',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _editTask(context, current),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Task'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroCard(TaskModel task, String status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8965F5), Color(0xFFB18CFF), Color(0xFFD0B8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  _categoryIcon(task.category),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            task.title,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _categoryName(task.category),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _heroDetail(Icons.calendar_month, _formatDate(task.dueAt)),
              _heroDetail(Icons.access_time, _formatTime(task.dueAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 17),
        const SizedBox(width: 7),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkColor,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _informationCard(TaskModel task, String status, Color statusColor) {
    return _whiteCard(
      Column(
        children: [
          _informationRow(
            Icons.category_outlined,
            'Category',
            _categoryName(task.category),
            primaryColor,
          ),
          _divider(),
          _informationRow(
            Icons.calendar_today_outlined,
            'Due Date',
            _formatDate(task.dueAt),
            Colors.orange,
          ),
          _divider(),
          _informationRow(
            Icons.access_time,
            'Due Time',
            _formatTime(task.dueAt),
            Colors.blue,
          ),
          _divider(),
          _informationRow(Icons.flag_outlined, 'Status', status, statusColor),
          _divider(),
          _informationRow(
            Icons.notifications_none,
            'Reminder',
            task.reminderAt == null
                ? 'Not set'
                : _formatDateTime(task.reminderAt!),
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _informationRow(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: darkColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard(TaskModel task) {
    final description = task.description.trim();

    return _whiteCard(
      Text(
        description.isEmpty
            ? 'No description added for this task.'
            : description,
        style: TextStyle(
          fontSize: 14,
          height: 1.7,
          color: description.isEmpty ? Colors.grey : darkColor,
        ),
      ),
    );
  }

  Widget _priorityCard(BuildContext context, WidgetRef ref, TaskModel task) {
    final color = _priorityColor(task.priority);

    return _whiteCard(
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.flag_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current priority',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _priorityName(task.priority),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _choosePriority(context, ref, task),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _checklistCard(BuildContext context, WidgetRef ref, TaskModel task) {
    final notifier = ref.read(taskProvider.notifier);
    final total = task.totalSubtasks;
    final completed = task.completedSubtasks;

    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completed of $total completed',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addSubtask(context, ref, task),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: task.subtaskProgress,
                minHeight: 7,
                backgroundColor: const Color(0xFFECE7FA),
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (task.subtasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No checklist items yet. Add steps to track your progress.',
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            )
          else
            ...task.subtasks.map(
              (subtask) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: subtask.isCompleted,
                      activeColor: primaryColor,
                      onChanged: (_) => _runAction(
                        context,
                        () => notifier.toggleSubtask(task.id, subtask.id),
                        'Could not update checklist.',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          color: darkColor,
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete checklist item',
                      onPressed: () =>
                          _confirmDeleteSubtask(context, ref, task, subtask),
                      icon: const Icon(
                        Icons.close,
                        size: 19,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tagsCard(BuildContext context, WidgetRef ref, TaskModel task) {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.tags.isEmpty)
            const Text('No tags added.', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFFF0EAFF),
                  labelStyle: const TextStyle(color: darkColor, fontSize: 12),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    final updated = [...task.tags]..remove(tag);
                    _runAction(
                      context,
                      () => ref
                          .read(taskProvider.notifier)
                          .updateTags(task.id, updated),
                      'Could not remove tag.',
                    );
                  },
                );
              }).toList(),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _editTags(context, ref, task),
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('Manage Tags'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context, WidgetRef ref, TaskModel task) {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.notes.trim().isEmpty
                ? 'No personal notes added yet.'
                : task.notes,
            style: TextStyle(
              color: task.notes.trim().isEmpty ? Colors.grey : darkColor,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _editNotes(context, ref, task),
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: Text(
                task.notes.trim().isEmpty ? 'Add Notes' : 'Edit Notes',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(TaskModel task) {
    return _whiteCard(
      Column(
        children: [
          _informationRow(
            Icons.add_circle_outline,
            'Created',
            _formatDateTime(task.createdAt),
            Colors.blue,
          ),
          _divider(),
          _informationRow(
            Icons.update,
            'Last updated',
            _formatDateTime(task.updatedAt),
            Colors.deepPurple,
          ),
          if (task.completedAt != null) ...[
            _divider(),
            _informationRow(
              Icons.check_circle_outline,
              'Completed',
              _formatDateTime(task.completedAt!),
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _whiteCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider() => const Divider(height: 24);

  // PRIORITY PICKER
  Future<void> _choosePriority(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final selected = await showModalBottomSheet<TaskPriority>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Priority',
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...TaskPriority.values.map((priority) {
                  final color = _priorityColor(priority);

                  return ListTile(
                    leading: Icon(Icons.flag, color: color),
                    title: Text(_priorityName(priority)),
                    trailing: task.priority == priority
                        ? const Icon(Icons.check, color: primaryColor)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, priority),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;

    await _runAction(
      context,
      () => ref.read(taskProvider.notifier).updatePriority(task.id, selected),
      'Could not update priority.',
    );
  }

  // ADD CHECKLIST ITEM
  Future<void> _addSubtask(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Checklist Item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'Enter checklist item',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (title == null || title.trim().isEmpty || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      () => ref.read(taskProvider.notifier).addSubtask(task.id, title),
      'Could not add checklist item.',
    );
  }

  // DELETE CHECKLIST ITEM
  Future<void> _confirmDeleteSubtask(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    TaskSubtask subtask,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove checklist item?'),
        content: Text('Remove "${subtask.title}" from this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await _runAction(
      context,
      () => ref.read(taskProvider.notifier).deleteSubtask(task.id, subtask.id),
      'Could not remove checklist item.',
    );
  }

  // EDIT NOTES
  Future<void> _editNotes(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final controller = TextEditingController(text: task.notes);

    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personal Notes'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Write your notes here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (notes == null || !context.mounted) return;

    await _runAction(
      context,
      () => ref.read(taskProvider.notifier).updateNotes(task.id, notes),
      'Could not save notes.',
    );
  }

  // MANAGE TAGS
  Future<void> _editTags(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final controller = TextEditingController(text: task.tags.join(', '));

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manage Tags'),
        content: TextField(
          controller: controller,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: 'work, urgent, personal',
            helperText: 'Separate tags with commas.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || !context.mounted) return;

    final tags = result
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    await _runAction(
      context,
      () => ref.read(taskProvider.notifier).updateTags(task.id, tags),
      'Could not save tags.',
    );
  }

  // EDIT TASK
  void _editTask(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
    );
  }

  // DELETE TASK
  Future<void> _deleteTask(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ref.read(taskProvider.notifier).deleteTask(task.id);

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      _showMessage(context, 'Could not delete task.');
    }
  }

  // COMMON SAFE ACTION
  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
    String errorMessage,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, errorMessage);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  String _categoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.study:
        return 'Study';
    }
  }

  IconData _categoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline;
      case TaskCategory.personal:
        return Icons.person_outline;
      case TaskCategory.study:
        return Icons.menu_book;
    }
  }

  String _priorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} • ${_formatTime(date)}';
  }
}
