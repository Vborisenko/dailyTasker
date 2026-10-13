class SubTask {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;

  const SubTask({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.order,
    required this.createdAt,
  });

  // Copy with method for immutability
  SubTask copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? order,
    DateTime? createdAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSON deserialization
  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubTask &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.order == order &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        isCompleted,
        order,
        createdAt,
      );

  @override
  String toString() {
    return 'SubTask(id: $id, title: $title, isCompleted: $isCompleted, order: $order)';
  }
}
