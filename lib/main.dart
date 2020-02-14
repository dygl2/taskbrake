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
      theme: themeData,
      home: TaskListPage(title: 'taskbrake'),
    );
  }
}
