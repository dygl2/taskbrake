import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/setting_popup_menu_button.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';
import 'package:taskbrake/task_edit_page.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DbProvider db;
  List<Task> _listTask = List<Task>();
  int _index = 0;

  _TaskListPageState();

  void _init() async {
    await DbProvider().database;
    _listTask = await DbProvider().getTaskAll();

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
        actions: <Widget>[
          SettingPopupMenuButton(),
        ],
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
            return Dismissible(
              key: Key(_listTask[index].id.toString()),
              onDismissed: (direction) {
                setState(() {
                  if (direction == DismissDirection.startToEnd) {
                    DbProvider().delete('task', _listTask[index].id);
                    _listTask.removeAt(index);

                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted'),
                      ),
                    );
                  }
                });
              },
              background: Container(
                color: Colors.greenAccent[50],
              ),
              child: Card(
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
                              value:
                                  (_listTask[index].status == Status.DONE.index)
                                      ? true
                                      : false,
                              onChanged: (bool e) {
                                setState(() {
                                  _listTask[index].status = e == true
                                      ? Status.DONE.index
                                      : Status.WIP.index;
                                  DbProvider().update('task', _listTask[index],
                                      _listTask[index].id);
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _edit(_listTask[index], index);
                    });
                  },
                ),
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
          id: id,
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
      _listTask[_index].id = task.id;
      _listTask[_index].title = task.title;
      _listTask[_index].status = task.status;
      _listTask[_index].deadline = task.deadline;

      DbProvider().update('task', task, _listTask[_index].id);
    });
  }
}
