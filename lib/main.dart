import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/task_model.dart';
import 'providers/task_provider.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final savedTasks = prefs.getString(tasksStorageKey);

  List<TaskModel> initialTasks = [];

  if (savedTasks != null && savedTasks.isNotEmpty) {
    try {
      final decoded = jsonDecode(savedTasks) as List;

      initialTasks = decoded.map((item) {
        return TaskModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (error) {
      debugPrint('Task loading error: $error');

      // Corrupted data par dummy tasks create nahi honge.
      initialTasks = [];
    }
  }

  runApp(
    ProviderScope(
      overrides: [taskProvider.overrideWith(() => TaskNotifier(initialTasks))],
      child: const TaskSphereApp(),
    ),
  );
}

class TaskSphereApp extends StatelessWidget {
  const TaskSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskSphere',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F2FF),
      ),
      home: const SplashScreen(),
    );
  }
}
