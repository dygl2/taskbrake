import 'package:taskbrake/data.dart';

class Task extends Data {
  int id;
  String title;
  int status;
  int deadline;
  int color;

  Task({this.id, this.title, this.status, this.deadline, this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'deadline': deadline,
      'color': color,
    };
  }
}
