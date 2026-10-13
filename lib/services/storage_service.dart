import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/sub_task.dart';

class StorageService {
  static const String _tasksBoxName = 'tasks';
  static const String _categoriesBoxName = 'categories';
  static const String _nextTaskIdKey = 'nextTaskId';
  static const String _nextCategoryIdKey = 'nextCategoryId';
  static const String _nextSubTaskIdKey = 'nextSubTaskId';
  static const String _schemaVersionKey = 'schemaVersion';
  static const int _currentSchemaVersion = 2; // Increment when schema changes

  static late Box<Task> _tasksBox;
  static late Box<TaskCategory> _categoriesBox;
  static late Box<int> _countersBox;

  // Initialize Hive
  static Future<void> init() async {
    try {
      debugPrint('StorageService: Starting Hive initialization...');
      await Hive.initFlutter();
      debugPrint('StorageService: Hive initialized successfully');
      
      // Register adapters for models
      debugPrint('StorageService: Registering Hive adapters...');
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(TaskCategoryAdapter());
      Hive.registerAdapter(SubTaskAdapter());
      Hive.registerAdapter(TaskPriorityAdapter());
      debugPrint('StorageService: Hive adapters registered successfully');
      
      // Open boxes
      debugPrint('StorageService: Opening boxes...');
      _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
      _categoriesBox = await Hive.openBox<TaskCategory>(_categoriesBoxName);
      _countersBox = await Hive.openBox<int>('counters');
      debugPrint('StorageService: All boxes opened successfully');
      
      // Initialize counters if they don't exist
      if (!_countersBox.containsKey(_nextTaskIdKey)) {
        _countersBox.put(_nextTaskIdKey, 1);
      }
      if (!_countersBox.containsKey(_nextCategoryIdKey)) {
        _countersBox.put(_nextCategoryIdKey, 1);
      }
      if (!_countersBox.containsKey(_nextSubTaskIdKey)) {
        _countersBox.put(_nextSubTaskIdKey, 1);
      }
      
      // Don't clear data on every startup - only during development/testing
      // await clearAllData();
      
      // Check schema version and migrate if needed
      await _checkAndMigrateSchema();
      
      // Update counters based on existing data
      await _updateCountersFromData();
    } catch (e) {
      debugPrint('Critical error during Hive initialization: $e');
      rethrow;
    }
  }

  // Check and migrate schema if needed
  static Future<void> _checkAndMigrateSchema() async {
    try {
      final storedVersion = _countersBox.get(_schemaVersionKey, defaultValue: 1);
      
      if ((storedVersion ?? 1) < _currentSchemaVersion) {
        debugPrint('Schema migration needed: $storedVersion -> $_currentSchemaVersion');
        
        // Clear all data for major schema changes
        await _tasksBox.clear();
        await _categoriesBox.clear();
        
        // Update schema version
        _countersBox.put(_schemaVersionKey, _currentSchemaVersion);
        
        debugPrint('Schema migration completed');
      }
    } catch (e) {
      debugPrint('Error during schema migration: $e');
      // If migration fails, clear everything and start fresh
      try {
        await _tasksBox.clear();
        await _categoriesBox.clear();
        _countersBox.put(_schemaVersionKey, _currentSchemaVersion);
      } catch (e2) {
        debugPrint('Failed to clear data after migration error: $e2');
      }
    }
  }

  // Force clear all data (for development/testing)
  static Future<void> clearAllData() async {
    try {
      await _tasksBox.clear();
      await _categoriesBox.clear();
      await _countersBox.clear();
      debugPrint('All data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  // Update counters based on existing data
  static Future<void> _updateCountersFromData() async {
    try {
      // Find maximum IDs in tasks
      if (_tasksBox.isNotEmpty) {
        final maxTaskId = _tasksBox.values.map((task) => task.id).reduce((a, b) => a > b ? a : b);
        _countersBox.put(_nextTaskIdKey, maxTaskId + 1);
      }
      
      // Find maximum IDs in categories
      if (_categoriesBox.isNotEmpty) {
        final maxCategoryId = _categoriesBox.values.map((cat) => cat.id).reduce((a, b) => a > b ? a : b);
        _countersBox.put(_nextCategoryIdKey, maxCategoryId + 1);
      }
      
      // Find maximum IDs in subtasks
      int maxSubTaskId = 0;
      for (final task in _tasksBox.values) {
        for (final subtask in task.subtasks) {
          if (subtask.id > maxSubTaskId) {
            maxSubTaskId = subtask.id;
          }
        }
      }
      if (maxSubTaskId > 0) {
        _countersBox.put(_nextSubTaskIdKey, maxSubTaskId + 1);
      }
    } catch (e) {
      // In case of error, leave counters as they are
      debugPrint('Error updating counters: $e');
    }
  }

  // Get next ID for tasks
  static int getNextTaskId() {
    final currentId = _countersBox.get(_nextTaskIdKey, defaultValue: 1);
    return currentId ?? 1;
  }

  // Increment ID for tasks
  static void incrementTaskId() {
    final currentId = _countersBox.get(_nextTaskIdKey, defaultValue: 1);
    _countersBox.put(_nextTaskIdKey, (currentId ?? 1) + 1);
  }

  // Get next ID for categories
  static int getNextCategoryId() {
    final currentId = _countersBox.get(_nextCategoryIdKey, defaultValue: 1);
    return currentId ?? 1;
  }

  // Increment ID for categories
  static void incrementCategoryId() {
    final currentId = _countersBox.get(_nextCategoryIdKey, defaultValue: 1);
    _countersBox.put(_nextCategoryIdKey, (currentId ?? 1) + 1);
  }

  // Get next ID for subtasks
  static int getNextSubTaskId() {
    final currentId = _countersBox.get(_nextSubTaskIdKey, defaultValue: 1);
    return currentId ?? 1;
  }

  // Increment ID for subtasks
  static void incrementSubTaskId() {
    final currentId = _countersBox.get(_nextSubTaskIdKey, defaultValue: 1);
    _countersBox.put(_nextSubTaskIdKey, (currentId ?? 1) + 1);
  }

  // Save tasks
  static Future<void> saveTasks(List<Task> tasks) async {
    await _tasksBox.clear();
    for (final task in tasks) {
      await _tasksBox.put(task.id.toString(), task);
    }
  }

  // Load tasks
  static List<Task> loadTasks() {
    try {
      if (!_tasksBox.isOpen) {
        debugPrint('StorageService: Tasks box is not open, returning empty list');
        return [];
      }
      final tasks = _tasksBox.values.toList();
      debugPrint('StorageService: Loading ${tasks.length} tasks from Hive');
      debugPrint('StorageService: Task IDs: ${tasks.map((t) => t.id).toList()}');
      debugPrint('StorageService: Box keys: ${_tasksBox.keys.toList()}');
      return tasks;
    } catch (e) {
      debugPrint('StorageService: Error loading tasks: $e');
      return [];
    }
  }

  // Save categories
  static Future<void> saveCategories(List<TaskCategory> categories) async {
    await _categoriesBox.clear();
    for (final category in categories) {
      await _categoriesBox.put(category.id.toString(), category);
    }
  }

  // Load categories
  static List<TaskCategory> loadCategories() {
    return _categoriesBox.values.toList();
  }

  // Add single task
  static Future<void> addTask(Task task) async {
    try {
      if (!_tasksBox.isOpen) {
        debugPrint('StorageService: Tasks box is not open, cannot add task');
        return;
      }
      
      debugPrint('StorageService: Adding task ${task.id} with title "${task.title}"');
      debugPrint('StorageService: Current box size before: ${_tasksBox.length}');
      
      // Ensure we have a valid key
      final key = task.id > 0 ? task.id.toString() : 'task_${DateTime.now().millisecondsSinceEpoch}';
      await _tasksBox.put(key, task);
      
      debugPrint('StorageService: Task added with key: $key. Current box size after: ${_tasksBox.length}');
      debugPrint('StorageService: All task IDs in box: ${_tasksBox.keys.toList()}');
    } catch (e) {
      debugPrint('StorageService: Error adding task: $e');
    }
  }

  // Update task
  static Future<void> updateTask(Task task) async {
    // Find the task by ID first, then update with the same key
    final existingKey = _tasksBox.keys.firstWhere(
      (key) => _tasksBox.get(key)?.id == task.id,
      orElse: () => task.id.toString(),
    );
    await _tasksBox.put(existingKey, task);
  }

  // Delete task
  static Future<void> deleteTask(int taskId) async {
    // Find the task by ID first, then delete with the same key
    final existingKey = _tasksBox.keys.firstWhere(
      (key) => _tasksBox.get(key)?.id == taskId,
      orElse: () => taskId.toString(),
    );
    await _tasksBox.delete(existingKey);
  }

  // Add category
  static Future<void> addCategory(TaskCategory category) async {
    await _categoriesBox.put(category.id.toString(), category);
  }

  // Update category
  static Future<void> updateCategory(TaskCategory category) async {
    await _categoriesBox.put(category.id.toString(), category);
  }

  // Delete category
  static Future<void> deleteCategory(int categoryId) async {
    await _categoriesBox.delete(categoryId.toString());
  }

  // Close boxes - disabled to prevent crashes
  static Future<void> close() async {
    debugPrint('StorageService: close() called but disabled to prevent crashes');
    // Don't close boxes manually - let Hive handle it automatically
    // This prevents crashes when app is terminated
  }
}

// Адаптеры для Hive
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final id = reader.readInt();
    final title = reader.readString();
    final description = reader.readString();
    final priority = TaskPriority.values[reader.readInt()];
    final categoryId = reader.readInt();
    final dueDateString = reader.readString();
    final dueDate = dueDateString.isNotEmpty ? DateTime.parse(dueDateString) : null;
    final isCompleted = reader.readBool();
    final createdAt = DateTime.parse(reader.readString());
    final subtasks = List<SubTask>.from(reader.readList());
    
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      categoryId: categoryId == 0 ? null : categoryId,
      dueDate: dueDate,
      isCompleted: isCompleted,
      createdAt: createdAt,
      subtasks: subtasks,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.priority.index);
    writer.writeInt(obj.categoryId ?? 0);
    writer.writeString(obj.dueDate?.toIso8601String() ?? '');
    writer.writeBool(obj.isCompleted);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeList(obj.subtasks);
  }
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 1;

  @override
  TaskCategory read(BinaryReader reader) {
    try {
      final id = reader.readInt();
      final name = reader.readString();
      final createdAt = DateTime.parse(reader.readString());
      
      // Try to read color, but handle case when it doesn't exist (backward compatibility)
      Color color;
      try {
        color = Color(reader.readInt());
      } catch (e) {
        // If color field doesn't exist, use default color
        color = Colors.blue;
      }
      
      return TaskCategory(
        id: id,
        name: name,
        createdAt: createdAt,
        color: color,
      );
    } catch (e) {
      debugPrint('Error reading TaskCategory: $e');
      // Return a default category if reading fails
      return TaskCategory(
        id: 0,
        name: 'Default',
        createdAt: DateTime.now(),
        color: Colors.blue,
      );
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeInt(obj.color.toARGB32());
  }
}

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 2;

  @override
  SubTask read(BinaryReader reader) {
    return SubTask(
      id: reader.readInt(),
      title: reader.readString(),
      description: reader.readString(),
      isCompleted: reader.readBool(),
      order: reader.readInt(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.order);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 3;

  @override
  TaskPriority read(BinaryReader reader) {
    return TaskPriority.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeInt(obj.index);
  }
}
