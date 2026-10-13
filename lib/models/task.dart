import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'sub_task.dart';

enum TaskPriority { low, medium, high }

class Task {
  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final int? categoryId;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final List<SubTask> subtasks;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.categoryId,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.subtasks = const [],
  });

  // Copy with method for immutability
  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskPriority? priority,
    int? categoryId,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    List<SubTask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
    };
  }

  // JSON deserialization
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      categoryId: json['categoryId'] as int?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((subtask) => SubTask.fromJson(subtask as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  // Get priority color
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  // Get completed subtasks count
  int get completedSubtasksCount => subtasks.where((subtask) => subtask.isCompleted).length;

  // Get total subtasks count
  int get totalSubtasksCount => subtasks.length;

  // Check if task has subtasks
  bool get hasSubtasks => subtasks.isNotEmpty;

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.categoryId == categoryId &&
        other.dueDate == dueDate &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        listEquals(other.subtasks, subtasks);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        priority,
        categoryId,
        dueDate,
        isCompleted,
        createdAt,
        Object.hashAll(subtasks),
      );

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted)';
  }
}
