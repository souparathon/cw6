class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;

  Task({required this.id, required this.name, this.isCompleted = false, this.priority = 'Low'});

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      name: data['name'],
      isCompleted: data['isCompleted'],
      priority: data['priority'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }
}
