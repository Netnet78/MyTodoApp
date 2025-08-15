class Task {
  final int? id; // null when not yet stored in DB
  final String title;
  final String? description;
  final bool isCompleted;
  final int importance;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.importance = 2
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'importance': importance,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      importance: map['importance'],
    );
  }
  
}
