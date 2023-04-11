// task.dart
class Task {
  Task({required this.title, this.dueDate, this.isCompleted = false});

  String title;
  DateTime? dueDate;
  bool isCompleted;

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }
}
