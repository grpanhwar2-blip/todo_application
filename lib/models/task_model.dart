enum TaskCategory { work, personal, study }

enum TaskPriority { low, medium, high, urgent }

class TaskSubtask {
  final String id;
  final String title;
  final bool isCompleted;

  const TaskSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  TaskSubtask copyWith({String? title, bool? isCompleted}) {
    return TaskSubtask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory TaskSubtask.fromJson(Map<String, dynamic> json) {
    return TaskSubtask(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final DateTime dueAt;
  final bool isCompleted;

  final TaskPriority priority;
  final List<TaskSubtask> subtasks;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderAt;
  final int colorValue;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueAt,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.subtasks = const [],
    this.tags = const [],
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderAt,
    this.colorValue = 0xFF8965F5,
    this.completedAt,
  }) : createdAt = createdAt ?? dueAt,
       updatedAt = updatedAt ?? dueAt;

  TaskModel copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? dueAt,
    bool? isCompleted,
    TaskPriority? priority,
    List<TaskSubtask>? subtasks,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    int? colorValue,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueAt: dueAt ?? this.dueAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
      colorValue: colorValue ?? this.colorValue,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'dueAt': dueAt.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.name,
      'subtasks': subtasks.map((item) => item.toJson()).toList(),
      'tags': tags,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'colorValue': colorValue,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      return DateTime.tryParse(value.toString()) ?? fallback;
    }

    final dueDate = parseDate(json['dueAt'], DateTime.now());

    TaskCategory parseCategory(dynamic value) {
      return TaskCategory.values.firstWhere(
        (item) => item.name == value,
        orElse: () => TaskCategory.personal,
      );
    }

    TaskPriority parsePriority(dynamic value) {
      return TaskPriority.values.firstWhere(
        (item) => item.name == value,
        orElse: () => TaskPriority.medium,
      );
    }

    final rawSubtasks = json['subtasks'];
    final rawTags = json['tags'];

    return TaskModel(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: parseCategory(json['category']),
      dueAt: dueDate,
      isCompleted: json['isCompleted'] == true,
      priority: parsePriority(json['priority']),
      subtasks: rawSubtasks is List
          ? rawSubtasks
                .whereType<Map>()
                .map(
                  (item) =>
                      TaskSubtask.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      tags: rawTags is List
          ? rawTags.map((item) => item.toString()).toList()
          : const [],
      notes: json['notes']?.toString() ?? '',
      createdAt: parseDate(json['createdAt'], dueDate),
      updatedAt: parseDate(json['updatedAt'], dueDate),
      reminderAt: json['reminderAt'] == null
          ? null
          : DateTime.tryParse(json['reminderAt'].toString()),
      colorValue: json['colorValue'] is int
          ? json['colorValue'] as int
          : 0xFF8965F5,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'].toString()),
    );
  }

  bool get isOverdue => !isCompleted && dueAt.isBefore(DateTime.now());

  int get completedSubtasks =>
      subtasks.where((item) => item.isCompleted).length;

  int get totalSubtasks => subtasks.length;

  double get subtaskProgress =>
      subtasks.isEmpty ? 0 : completedSubtasks / totalSubtasks;
}
