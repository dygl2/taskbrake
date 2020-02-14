import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key key, this.title, this.date}) : super(key: key);
  final String title;
  DateTime date;

  @override
  _TaskListPageState createState() => _TaskListPageState(this.date);
}

class _TaskListPageState extends State<TaskListPage> {
  DbProvider db;
  List<Task> _listTask = List<Task>();
  DateTime _date;

  _TaskListPageState(this._date);

  void _init() async {
    await DbProvider().database;
    _listTask = await DbProvider().getTaskAll();

    Task tmp1 = new Task(
        taskId: DateTime.now().millisecondsSinceEpoch,
        title: 'test1',
        status: Status.WIP.index,
        deadline: DateTime.now().millisecondsSinceEpoch);
    _listTask.add(tmp1);

    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _listTask.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        _listTask[index].title,
                        style: TextStyle(
                            color: DateTime.now().isBefore(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _listTask[index].deadline))
                                ? Colors.black
                                : Colors.redAccent),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        DateFormat.yMMMd().format(
                            DateTime.fromMillisecondsSinceEpoch(
                                _listTask[index].deadline)),
                        // highlight expired item
                        style: TextStyle(
                            color: DateTime.now().isBefore(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _listTask[index].deadline))
                                ? Colors.black
                                : Colors.redAccent),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Checkbox(
                          activeColor: Colors.green[300],
                          value: (_listTask[index].status == Status.DONE.index)
                              ? true
                              : false,
                          onChanged: _setCheckbox,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {});
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _setCheckbox(bool e) {
    setState(() {});
  }
}
