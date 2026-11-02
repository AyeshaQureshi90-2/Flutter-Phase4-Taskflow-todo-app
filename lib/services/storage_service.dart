
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  static Future<void> saveTasks(
    List<Map<String, dynamic>> tasks,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final tasksJson = jsonEncode(
      tasks.map((task) {
        return {
          'title': task['title'],
          'description': task['description'],
          'date': (task['date'] as DateTime?)?.toIso8601String(),
          'isCompleted': task['isCompleted'] ?? false,
        };
      }).toList(),
    );

    await prefs.setString(_tasksKey, tasksJson);
  }

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);

    if (tasksJson == null) {
      return [];
    }

    final List<dynamic> decodedTasks = jsonDecode(tasksJson);

    return decodedTasks.map((task) {
      final map = Map<String, dynamic>.from(task);

      return {
        'title': map['title'] as String,
        'description': map['description'] as String? ?? '',
        'date': map['date'] == null
            ? null
            : DateTime.parse(map['date'] as String),
        'isCompleted': map['isCompleted'] as bool? ?? false,
      };
    }).toList();
  }
}
