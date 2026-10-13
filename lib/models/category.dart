import 'package:flutter/material.dart';

class TaskCategory {
  final int id;
  final String name;
  final DateTime createdAt;
  final Color color;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color = Colors.blue,
  });

  // Copy with method for immutability
  TaskCategory copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    Color? color,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'color': color.toARGB32(),
    };
  }

  // JSON deserialization
  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      color: Color(json['color'] as int? ?? Colors.blue.toARGB32()),
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCategory &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, color);

  @override
  String toString() {
    return 'TaskCategory(id: $id, name: $name, createdAt: $createdAt, color: $color)';
  }
}
