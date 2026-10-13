import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/sub_task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  int _nextSubTaskId = 1;

  // Initialize provider
  Future<void> initialize() async {
    await _loadTasks();
    await _loadCounters();
  }

  // Reload tasks from storage
  Future<void> reloadTasks() async {
    await _loadTasks();
  }

  // Load tasks from database
  Future<void> _loadTasks() async {
    _tasks = StorageService.loadTasks();
    debugPrint('Loaded ${_tasks.length} tasks from storage');
    debugPrint('Task IDs: ${_tasks.map((t) => t.id).toList()}');
    notifyListeners();
  }

  // Load counters from database
  Future<void> _loadCounters() async {
    try {
      _nextSubTaskId = StorageService.getNextSubTaskId();
      
      // Update counters based on existing data
      if (_tasks.isNotEmpty) {
        // This will be handled by StorageService._updateCountersFromData()
        final maxSubTaskId = _tasks
            .expand((task) => task.subtasks)
            .map((subtask) => subtask.id)
            .fold(1, (max, id) => id > max ? id : max);
        if (maxSubTaskId > 0) {
          _nextSubTaskId = maxSubTaskId + 1;
        }
      }
    } catch (e) {
      // In case of error, continue without updating counters
      debugPrint('Error loading task counters: $e');
    }
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  
  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) => 
        task.dueDate != null &&
        task.dueDate!.year == today.year &&
        task.dueDate!.month == today.month &&
        task.dueDate!.day == today.day
    ).toList();
  }

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();

  // Create new task
  Future<void> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    int? categoryId,
    DateTime? dueDate,
    List<SubTask> subtasks = const [],
  }) async {
    if (title.trim().isEmpty) return;

    // Get ID for task and subtasks
    final taskId = StorageService.getNextTaskId();
    final updatedSubtasks = subtasks.map((subtask) => subtask.copyWith(
      id: StorageService.getNextSubTaskId(),
    )).toList();

    final task = Task(
      id: taskId,
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      categoryId: categoryId,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      subtasks: updatedSubtasks,
    );

    debugPrint('Adding task: ${task.title} with ID: ${task.id}');
    debugPrint('Current tasks count: ${_tasks.length}');
    
    _tasks.add(task);
    await StorageService.addTask(task);
    
    debugPrint('Task added to storage. Current tasks count: ${_tasks.length}');
    
    // Increment counters
    StorageService.incrementTaskId();
    for (int i = 0; i < updatedSubtasks.length; i++) {
      StorageService.incrementSubTaskId();
    }
    
    _nextSubTaskId = StorageService.getNextSubTaskId();
    
    debugPrint('Notifying listeners. Tasks count: ${_tasks.length}');
    notifyListeners();
    
    // Reload tasks from storage to ensure consistency
    await _loadTasks();
    debugPrint('After reload: Tasks count: ${_tasks.length}');
    notifyListeners();
  }

  // Update existing task
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await StorageService.updateTask(task);
      notifyListeners();
    }
  }

  // Delete task
  Future<void> deleteTask(int taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await StorageService.deleteTask(taskId);
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(int taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await StorageService.updateTask(_tasks[index]);
      notifyListeners();
    }
  }

  // Add subtask to task
  Future<void> addSubTask(int taskId, String title, String description) async {
    if (title.trim().isEmpty) return;

    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final subtaskId = StorageService.getNextSubTaskId();
      final subtask = SubTask(
        id: subtaskId,
        title: title.trim(),
        description: description.trim(),
        order: task.subtasks.length,
        createdAt: DateTime.now(),
      );

      final updatedSubtasks = List<SubTask>.from(task.subtasks)..add(subtask);
      _tasks[index] = task.copyWith(subtasks: updatedSubtasks);
      await StorageService.updateTask(_tasks[index]);
      
      // Increment subtask counter
      StorageService.incrementSubTaskId();
      _nextSubTaskId = StorageService.getNextSubTaskId();
      
      notifyListeners();
    }
  }

  // Update subtask
  Future<void> updateSubTask(int taskId, int subtaskId, String title, String description) async {
    if (title.trim().isEmpty) return;

    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subtaskIndex = task.subtasks.indexWhere((subtask) => subtask.id == subtaskId);
      
      if (subtaskIndex != -1) {
        final updatedSubtasks = List<SubTask>.from(task.subtasks);
        updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
          title: title.trim(),
          description: description.trim(),
        );
        
        _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
        await StorageService.updateTask(_tasks[taskIndex]);
        notifyListeners();
      }
    }
  }

  // Delete subtask
  Future<void> deleteSubTask(int taskId, int subtaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = task.subtasks.where((subtask) => subtask.id != subtaskId).toList();
      
      _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      await StorageService.updateTask(_tasks[taskIndex]);
      notifyListeners();
    }
  }

  // Toggle subtask completion
  Future<void> toggleSubTaskCompletion(int taskId, int subtaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subtaskIndex = task.subtasks.indexWhere((subtask) => subtask.id == subtaskId);
      
      if (subtaskIndex != -1) {
        final updatedSubtasks = List<SubTask>.from(task.subtasks);
        updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
          isCompleted: !updatedSubtasks[subtaskIndex].isCompleted,
        );
        
        _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
        await StorageService.updateTask(_tasks[taskIndex]);
        notifyListeners();
      }
    }
  }

  // Reorder subtasks
  Future<void> reorderSubtasks(int taskId, int oldIndex, int newIndex) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = List<SubTask>.from(task.subtasks);
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final subtask = updatedSubtasks.removeAt(oldIndex);
      updatedSubtasks.insert(newIndex, subtask);
      
      // Update order values
      for (int i = 0; i < updatedSubtasks.length; i++) {
        updatedSubtasks[i] = updatedSubtasks[i].copyWith(order: i);
      }
      
      _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      await StorageService.updateTask(_tasks[taskIndex]);
      notifyListeners();
    }
  }

  // Update subtask completion status by ID
  Future<void> updateSubTaskCompletion(int taskId, int subtaskId, bool isCompleted) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subtaskIndex = task.subtasks.indexWhere((subtask) => subtask.id == subtaskId);
      
      if (subtaskIndex != -1) {
        final updatedSubtasks = List<SubTask>.from(task.subtasks);
        updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
          isCompleted: isCompleted,
        );
        
        _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
        await StorageService.updateTask(_tasks[taskIndex]);
        notifyListeners();
      }
    }
  }

  // Update subtask completion status by index
  Future<void> updateSubTaskCompletionByIndex(int taskId, int subtaskIndex, bool isCompleted) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      
      if (subtaskIndex >= 0 && subtaskIndex < task.subtasks.length) {
        final updatedSubtasks = List<SubTask>.from(task.subtasks);
        updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
          isCompleted: isCompleted,
        );
        
        _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
        await StorageService.updateTask(_tasks[taskIndex]);
        notifyListeners();
      }
    }
  }

  // Get tasks by category
  List<Task> getTasksByCategory(int categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // Get tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Search tasks by title
  List<Task> searchTasks(String query) {
    if (query.trim().isEmpty) return _tasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) => 
        task.title.toLowerCase().contains(lowercaseQuery) ||
        task.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get task by ID
  Task? getTaskById(int taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Get next subtask ID (for editing tasks)
  int getNextSubTaskId() {
    return _nextSubTaskId;
  }

  // Get task statistics
  Map<String, int> getTaskStatistics() {
    return {
      'total': _tasks.length,
      'completed': completedTasks.length,
      'pending': pendingTasks.length,
      'highPriority': getTasksByPriority(TaskPriority.high).length,
      'mediumPriority': getTasksByPriority(TaskPriority.medium).length,
      'lowPriority': getTasksByPriority(TaskPriority.low).length,
    };
  }
}
