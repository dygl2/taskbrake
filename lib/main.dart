import 'package:flutter/material.dart';
import 'package:taskbrake/theme.dart';
import 'package:taskbrake/task_list_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'taskbrake',
      theme: new ThemeData(primaryColor: Colors.grey),
      home: TaskListPage(title: 'taskbrake'),
    );
  }
}
