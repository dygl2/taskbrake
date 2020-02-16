import 'package:taskbrake/data.dart';

class Proc extends Data {
  int id;
  int taskId;
  int number;
  String content;
  int time;
  int date;
  int status;

  Proc(
      {this.id,
      this.taskId,
      this.number,
      this.content,
      this.time,
      this.date,
      this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'number': number,
      'content': content,
      'time': time,
      'date': date,
      'status': status,
    };
  }
}

enum Status {
  WIP,
  DONE,
}
