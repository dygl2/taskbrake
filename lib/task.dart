import 'package:taskbrake/data.dart';

class Task extends Data {
  int taskId;
  String title;
  int status;
  int deadline;

  Task({this.taskId, this.title, this.status, this.deadline});

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'status': status,
      'deadline': deadline,
    };
  }
}
