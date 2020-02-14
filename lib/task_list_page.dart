import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';
import 'package:taskbrake/task_edit_page.dart';

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
  int _index = 0;
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
        onPressed: () {
          _add();
        },
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
                  setState(() {
                    _edit(_listTask[index], _index);
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _add() {
    setState(() {
      _index = _listTask.length;
      int id = DateTime.now().millisecondsSinceEpoch;
      Task task = new Task(
          taskId: id,
          title: "",
          status: Status.WIP.index,
          deadline: DateTime.now().millisecondsSinceEpoch);
      DbProvider().insert('task', task);
      _listTask.add(task);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return TaskEditPage(task, _onChanged);
      }));
    });
  }

  void _edit(Task task, int index) {
    setState(() {
      _index = index;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return TaskEditPage(task, _onChanged);
      }));
    });
  }

  void _onChanged(Task task) {
    setState(() {
      _listTask[_index].taskId = task.taskId;
      _listTask[_index].title = task.title;
      _listTask[_index].status = task.status;
      _listTask[_index].deadline = task.deadline;

      DbProvider().update('task', task, _listTask[_index].taskId);
    });
  }

  void _setCheckbox(bool e) {
    setState(() {});
  }
}
