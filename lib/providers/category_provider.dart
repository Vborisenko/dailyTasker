import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryProvider with ChangeNotifier {
  List<TaskCategory> _categories = [];

  // Initialize provider
  Future<void> initialize() async {
    await _loadCategories();
    await _loadCounters();
  }

  // Load categories from database
  Future<void> _loadCategories() async {
    _categories = StorageService.loadCategories();
    notifyListeners();
  }

  // Load counters from database
  Future<void> _loadCounters() async {
    try {
      // Update counters based on existing data
      if (_categories.isNotEmpty) {
        final maxId = _categories.map((category) => category.id).reduce((a, b) => a > b ? a : b);
        // Update storage counter if needed
        if (StorageService.getNextCategoryId() <= maxId) {
          // This will be handled by StorageService._updateCountersFromData()
        }
      }
    } catch (e) {
      // In case of error, continue without updating counters
      debugPrint('Error loading category counters: $e');
    }
  }

  List<TaskCategory> get categories => List.unmodifiable(_categories);

  // Create new category
  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    
    // Check for duplicate names
    if (_categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
      return;
    }

    final categoryId = StorageService.getNextCategoryId();
    final category = TaskCategory(
      id: categoryId,
      name: name.trim(),
      createdAt: DateTime.now(),
    );

    _categories.add(category);
    await StorageService.addCategory(category);
    
    // Increment counter
    StorageService.incrementCategoryId();
    
    notifyListeners();
  }

  // Update category
  Future<void> updateCategory(int id, String newName) async {
    if (newName.trim().isEmpty) return;
    
    // Check for duplicate names (excluding current category)
    if (_categories.any((cat) => 
        cat.id != id && cat.name.toLowerCase() == newName.toLowerCase())) {
      return;
    }

    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(name: newName.trim());
      await StorageService.updateCategory(_categories[index]);
      notifyListeners();
    }
  }

  // Delete category
  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((cat) => cat.id == id);
    await StorageService.deleteCategory(id);
    
    // Update tasks that use this category
    await _updateTasksWithDeletedCategory(id);
    
    notifyListeners();
  }

  // Update tasks that use a deleted category
  Future<void> _updateTasksWithDeletedCategory(int deletedCategoryId) async {
    try {
      final tasks = StorageService.loadTasks();
      bool hasChanges = false;
      
      for (final task in tasks) {
        if (task.categoryId == deletedCategoryId) {
          // Update task to remove category reference
          final updatedTask = task.copyWith(categoryId: null);
          await StorageService.updateTask(updatedTask);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        debugPrint('Updated tasks that were using deleted category $deletedCategoryId');
      }
    } catch (e) {
      debugPrint('Error updating tasks with deleted category: $e');
    }
  }

  // Bulk delete categories
  Future<void> deleteCategories(List<int> ids) async {
    _categories.removeWhere((cat) => ids.contains(cat.id));
    for (final id in ids) {
      await StorageService.deleteCategory(id);
    }
    
    // Update tasks that use any of the deleted categories
    for (final id in ids) {
      await _updateTasksWithDeletedCategory(id);
    }
    
    notifyListeners();
  }

  // Get category by ID
  TaskCategory? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if category exists
  bool categoryExists(String name) {
    return _categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }
}
