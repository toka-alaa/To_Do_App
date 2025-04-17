class Task
{
  String title ;
  String? description;
  int? id;
  DateTime createdAt;
  bool isCompleted;


  Task({
     this.id,
    required this.title,
     this.description,
    required this.createdAt,
    this.isCompleted = false,
  });


  Map <String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

}