import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/task_model.dart';
import 'providers/task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const AddTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  late TaskCategory selectedCategory;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  bool isLoading = false;
  bool obscureDescription = false;

  bool get isEditing => widget.task != null;

  static const Color primary = Color(0xFF8965F5);
  static const Color dark = Color(0xFF30234A);
  static const Color background = Color(0xFFF5F2FF);

  @override
  void initState() {
    super.initState();

    final existingTask = widget.task;

    titleController = TextEditingController(text: existingTask?.title ?? '');

    descriptionController = TextEditingController(
      text: existingTask?.description ?? '',
    );

    selectedCategory = existingTask?.category ?? TaskCategory.work;

    final initialDate = existingTask?.dueAt ?? DateTime.now();

    selectedDate = DateUtils.dateOnly(initialDate);

    selectedTime = TimeOfDay.fromDateTime(initialDate);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ==========================================
  // CATEGORY INFORMATION
  // ==========================================

  String categoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.study:
        return 'Study';
    }
  }

  IconData categoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline_rounded;
      case TaskCategory.personal:
        return Icons.person_outline_rounded;
      case TaskCategory.study:
        return Icons.menu_book_rounded;
    }
  }

  Color categoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFFFFE2D5);
      case TaskCategory.personal:
        return const Color(0xFFD2F5E9);
      case TaskCategory.study:
        return const Color(0xFFDCD5FF);
    }
  }

  // ==========================================
  // DATE PICKER
  // ==========================================

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select task deadline',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = DateUtils.dateOnly(date);
      });
    }
  }

  // ==========================================
  // TIME PICKER
  // ==========================================

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      helpText: 'Select task time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // ==========================================
  // COMBINE DATE AND TIME
  // ==========================================

  DateTime get selectedDueAt {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  // ==========================================
  // FORM VALIDATION
  // ==========================================

  String? validateTitle(String? value) {
    final title = value?.trim() ?? '';

    if (title.isEmpty) {
      return 'Task title is required';
    }

    if (title.length < 3) {
      return 'Title must contain at least 3 characters';
    }

    if (title.length > 60) {
      return 'Title cannot exceed 60 characters';
    }

    final tasks = ref.read(taskProvider);

    final duplicateExists = tasks.any((task) {
      final sameTitle = task.title.trim().toLowerCase() == title.toLowerCase();

      final differentTask = !isEditing || task.id != widget.task!.id;

      return sameTitle && differentTask;
    });

    if (duplicateExists) {
      return 'A task with this title already exists';
    }

    return null;
  }

  bool validateDueDate() {
    if (selectedDueAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return false;
    }

    return true;
  }

  // ==========================================
  // SAVE TASK - ADD / EDIT
  // ==========================================

  Future<void> saveTask() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!validateDueDate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final notifier = ref.read(taskProvider.notifier);

      if (isEditing) {
        await notifier.editTask(
          id: widget.task!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          category: selectedCategory,
          dueAt: selectedDueAt,
        );
      } else {
        await notifier.addTask(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          category: selectedCategory,
          dueAt: selectedDueAt,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to ${isEditing ? 'update' : 'create'} task: $error',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // ==========================================
  // RESET FORM
  // ==========================================

  void resetForm() {
    setState(() {
      titleController.clear();
      descriptionController.clear();

      selectedCategory = TaskCategory.work;
      selectedDate = DateUtils.dateOnly(DateTime.now());
      selectedTime = TimeOfDay.now();
    });

    _formKey.currentState?.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleared successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // CHECK UNSAVED CHANGES
  // ==========================================

  bool get hasChanges {
    if (isEditing) {
      final original = widget.task!;

      return titleController.text.trim() != original.title ||
          descriptionController.text.trim() != original.description ||
          selectedCategory != original.category ||
          selectedDueAt != original.dueAt;
    }

    return titleController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty ||
        selectedCategory != TaskCategory.work ||
        selectedDueAt.difference(DateTime.now()).inMinutes.abs() > 2;
  }

  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your unsaved changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> handleBack() async {
    if (isLoading) return;

    final shouldLeave = await confirmDiscard();

    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  // ==========================================
  // BUILD SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleBack();
      },
      child: Scaffold(
        backgroundColor: background,

        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          leading: IconButton(
            onPressed: isLoading ? null : handleBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            isEditing ? 'Edit Task' : 'Create New Task',
            style: const TextStyle(fontWeight: FontWeight.bold, color: dark),
          ),
          centerTitle: true,
          actions: [
            if (!isEditing)
              IconButton(
                tooltip: 'Reset form',
                onPressed: isLoading ? null : resetForm,
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        ),

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),

                          const SizedBox(height: 28),

                          _sectionTitle('Task Title'),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: titleController,
                            enabled: !isLoading,
                            maxLength: 60,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                            ],
                            decoration: inputDecoration(
                              hint: 'What do you need to do?',
                              icon: Icons.edit_note_rounded,
                            ),
                            validator: validateTitle,
                          ),

                          const SizedBox(height: 18),

                          _sectionTitle('Description'),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: descriptionController,
                            enabled: !isLoading,
                            maxLines: 4,
                            minLines: 3,
                            maxLength: 200,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            decoration: inputDecoration(
                              hint: 'Add some details (optional)',
                              icon: Icons.notes_rounded,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _sectionTitle('Choose Category'),

                          const SizedBox(height: 12),

                          _buildCategories(),

                          const SizedBox(height: 25),

                          _sectionTitle('Schedule Task'),

                          const SizedBox(height: 12),

                          _buildSchedule(),

                          const SizedBox(height: 15),

                          _buildDeadlineInfo(),

                          const SizedBox(height: 30),

                          _buildSaveButton(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HEADER CARD
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8965F5), Color(0xFFB18CFF), Color(0xFFCEB7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Make it even better!'
                      : 'Plan something amazing!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing
                      ? 'Update your task details below.'
                      : 'Small tasks create big achievements.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.rocket_launch_rounded,
            size: 45,
            color: Color(0xFFFFD45C),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY SELECTOR
  // ==========================================

  Widget _buildCategories() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: TaskCategory.values.map((category) {
        final selected = selectedCategory == category;

        return Semantics(
          button: true,
          selected: selected,
          label: categoryName(category),
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: selected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? primary : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoryIcon(category),
                    color: selected ? Colors.white : dark,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName(category),
                    style: TextStyle(
                      color: selected ? Colors.white : dark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // DATE AND TIME SELECTOR
  // ==========================================

  Widget _buildSchedule() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 420;

        final cardWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _scheduleCard(
                title: 'Deadline Date',
                value:
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                icon: Icons.calendar_month_rounded,
                onTap: pickDate,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _scheduleCard(
                title: 'Deadline Time',
                value: selectedTime.format(context),
                icon: Icons.access_time_rounded,
                onTap: pickTime,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _scheduleCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DEADLINE INFORMATION
  // ==========================================

  Widget _buildDeadlineInfo() {
    final now = DateTime.now();
    final overdue = selectedDueAt.isBefore(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: overdue ? const Color(0xFFFFE8E8) : const Color(0xFFEDE7FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            overdue ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: overdue ? Colors.red : primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              overdue
                  ? 'This deadline is in the past. Please choose a future time.'
                  : 'Your task deadline is ${selectedDueAt.toLocal()}.',
              style: TextStyle(
                color: overdue ? Colors.red.shade800 : dark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SAVE BUTTON
  // ==========================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 5,
        ),
        child: isLoading
            ? const SizedBox(
                height: 23,
                width: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEditing ? Icons.save_rounded : Icons.add_task_rounded),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==========================================
  // REUSABLE SECTION TITLE
  // ==========================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: dark,
      ),
    );
  }

  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
