import 'package:taskbrake/data.dart';

class Task extends Data {
  int id;
  String title;
  int status;
  int deadline;

  Task({this.id, this.title, this.status, this.deadline});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'deadline': deadline,
    };
  }
}
