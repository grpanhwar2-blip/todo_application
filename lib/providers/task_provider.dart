import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

const String tasksStorageKey = 'tasks';

final taskProvider = NotifierProvider<TaskNotifier, List<TaskModel>>(
  TaskNotifier.new,
);

class TaskNotifier extends Notifier<List<TaskModel>> {
  final List<TaskModel> initialTasks;

  Future<void> _pendingSave = Future<void>.value();

  TaskNotifier([this.initialTasks = const []]);

  @override
  List<TaskModel> build() => initialTasks;

  Future<void> _saveTasks() {
    final snapshot = state.map((task) => task.toJson()).toList();
    final encoded = jsonEncode(snapshot);

    _pendingSave = _pendingSave.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(tasksStorageKey, encoded);

      if (!saved) {
        throw Exception('Could not save tasks.');
      }
    });

    return _pendingSave;
  }

  Future<void> _updateTask(
    String id,
    TaskModel Function(TaskModel task) update,
  ) async {
    final index = state.indexWhere((task) => task.id == id);

    if (index == -1) {
      throw Exception('Task not found.');
    }

    final updatedTask = update(state[index]);

    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index) updatedTask else state[i],
    ];

    await _saveTasks();
  }

  // ADD TASK
  Future<void> addTask({
    required String title,
    required String description,
    required TaskCategory category,
    required DateTime dueAt,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();

    final newTask = TaskModel(
      id: now.microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      dueAt: dueAt,
      priority: priority,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );

    state = [...state, newTask];
    await _saveTasks();
  }

  // EDIT EXISTING TASK
  Future<void> editTask({
    required String id,
    required String title,
    required String description,
    required TaskCategory category,
    required DateTime dueAt,
  }) async {
    await _updateTask(id, (task) {
      return task.copyWith(
        title: title.trim(),
        description: description.trim(),
        category: category,
        dueAt: dueAt,
        updatedAt: DateTime.now(),
      );
    });
  }

  // TOGGLE COMPLETION
  Future<void> toggleTask(String id) async {
    await _updateTask(id, (task) {
      final completed = !task.isCompleted;

      return task.copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
        clearCompletedAt: !completed,
        updatedAt: DateTime.now(),
      );
    });
  }

  // SET COMPLETION DIRECTLY
  Future<void> setTaskCompleted(String id, bool completed) async {
    await _updateTask(id, (task) {
      return task.copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
        clearCompletedAt: !completed,
        updatedAt: DateTime.now(),
      );
    });
  }

  // DELETE TASK
  Future<void> deleteTask(String id) async {
    final previous = state;
    state = state.where((task) => task.id != id).toList();

    try {
      await _saveTasks();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  // PRIORITY
  Future<void> updatePriority(String id, TaskPriority priority) async {
    await _updateTask(
      id,
      (task) => task.copyWith(priority: priority, updatedAt: DateTime.now()),
    );
  }

  // NOTES
  Future<void> updateNotes(String id, String notes) async {
    await _updateTask(
      id,
      (task) => task.copyWith(notes: notes.trim(), updatedAt: DateTime.now()),
    );
  }

  // TAGS
  Future<void> updateTags(String id, List<String> tags) async {
    final cleanedTags = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    await _updateTask(
      id,
      (task) => task.copyWith(tags: cleanedTags, updatedAt: DateTime.now()),
    );
  }

  // ADD SUBTASK
  Future<void> addSubtask(String taskId, String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    await _updateTask(taskId, (task) {
      final subtask = TaskSubtask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: cleanTitle,
      );

      return task.copyWith(
        subtasks: [...task.subtasks, subtask],
        updatedAt: DateTime.now(),
      );
    });
  }

  // UPDATE SUBTASK COMPLETION
  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    await _updateTask(taskId, (task) {
      final updated = task.subtasks.map((subtask) {
        if (subtask.id == subtaskId) {
          return subtask.copyWith(isCompleted: !subtask.isCompleted);
        }
        return subtask;
      }).toList();

      return task.copyWith(subtasks: updated, updatedAt: DateTime.now());
    });
  }

  // EDIT SUBTASK TITLE
  Future<void> editSubtask({
    required String taskId,
    required String subtaskId,
    required String title,
  }) async {
    await _updateTask(taskId, (task) {
      final updated = task.subtasks.map((subtask) {
        if (subtask.id == subtaskId) {
          return subtask.copyWith(title: title.trim());
        }
        return subtask;
      }).toList();

      return task.copyWith(subtasks: updated, updatedAt: DateTime.now());
    });
  }

  // DELETE SUBTASK
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    await _updateTask(taskId, (task) {
      return task.copyWith(
        subtasks: task.subtasks.where((item) => item.id != subtaskId).toList(),
        updatedAt: DateTime.now(),
      );
    });
  }

  // UPDATE DUE DATE
  Future<void> updateDueDate(String id, DateTime dueAt) async {
    await _updateTask(
      id,
      (task) => task.copyWith(dueAt: dueAt, updatedAt: DateTime.now()),
    );
  }

  // SET / CLEAR REMINDER TIME
  Future<void> updateReminder(String id, DateTime? reminderAt) async {
    await _updateTask(
      id,
      (task) => task.copyWith(
        reminderAt: reminderAt,
        clearReminder: reminderAt == null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // UPDATE TASK COLOR
  Future<void> updateTaskColor(String id, int colorValue) async {
    await _updateTask(
      id,
      (task) =>
          task.copyWith(colorValue: colorValue, updatedAt: DateTime.now()),
    );
  }

  // DELETE COMPLETED
  Future<void> deleteCompletedTasks() async {
    final previous = state;
    state = state.where((task) => !task.isCompleted).toList();

    try {
      await _saveTasks();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  // CLEAR ALL
  Future<void> clearAllTasks() async {
    final previous = state;
    state = [];

    try {
      await _saveTasks();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  // GET TASK
  TaskModel? getTaskById(String id) {
    for (final task in state) {
      if (task.id == id) return task;
    }
    return null;
  }

  // FILTERS
  List<TaskModel> filterTasks(TaskCategory? category) {
    if (category == null) return state;

    return state.where((task) => task.category == category).toList();
  }

  List<TaskModel> searchTasks(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) return state;

    return state.where((task) {
      return task.title.toLowerCase().contains(value) ||
          task.description.toLowerCase().contains(value) ||
          task.notes.toLowerCase().contains(value) ||
          task.tags.any((tag) => tag.toLowerCase().contains(value));
    }).toList();
  }

  List<TaskModel> get completedTasks =>
      state.where((task) => task.isCompleted).toList();

  List<TaskModel> get pendingTasks =>
      state.where((task) => !task.isCompleted).toList();

  List<TaskModel> get overdueTasks =>
      state.where((task) => task.isOverdue).toList();

  List<TaskModel> get todayTasks {
    final now = DateTime.now();

    return state.where((task) {
      return task.dueAt.year == now.year &&
          task.dueAt.month == now.month &&
          task.dueAt.day == now.day;
    }).toList();
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();

    return state
        .where((task) => !task.isCompleted && task.dueAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<TaskModel> get prioritySortedTasks {
    final tasks = [...state];

    tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return tasks;
  }
}
