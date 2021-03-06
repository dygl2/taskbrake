import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/setting_popup_menu_button.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';
import 'package:taskbrake/task_edit_page.dart';
import 'package:taskbrake/task_color.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DbProvider db;
  List<Task> _listTask = List<Task>();
  static const int DAYS_OF_WEEK = 7;
  static const double DATE_LABEL_HEIGHT = 22.0;
  static const double PROC_LIST_HEIGHT = 180.0;
  DateFormat _format;
  List<List<Proc>> _listProc = List<List<Proc>>();
  int _index = 0;

  _TaskListPageState();

  void _init() async {
    await DbProvider().database;

    _listTask = await DbProvider().getTaskAll();
    List<Proc> tmp = List<Proc>();
    _listProc.clear();

    for (int i = 0; i < DAYS_OF_WEEK; i++) {
      _listProc.add(List<Proc>());

      tmp = await DbProvider().getProcOnDate(
          DateTime.now().add(Duration(days: i)).millisecondsSinceEpoch);

      if (tmp != null && tmp.length > 0) {
        _listProc[i].addAll(tmp);
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    initializeDateFormatting('ja');
    _format = DateFormat('yyyy-MM-dd', 'ja');

    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _setDateText(Duration(days: 0)),
              _setProcListOnDate(0),
              _setDateText(Duration(days: 1)),
              _setProcListOnDate(1),
              _setDateText(Duration(days: 2)),
              _setProcListOnDate(2),
              _setDateText(Duration(days: 3)),
              _setProcListOnDate(3),
              _setDateText(Duration(days: 4)),
              _setProcListOnDate(4),
              _setDateText(Duration(days: 5)),
              _setProcListOnDate(5),
              _setDateText(Duration(days: 6)),
              _setProcListOnDate(6),
            ],
          ),
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
          deadline: DateTime.now().millisecondsSinceEpoch,
          color: 0);
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

  void _onChanged(Task task) async {
    setState(() {
      _listTask[_index].id = task.id;
      _listTask[_index].title = task.title;
      _listTask[_index].status = task.status;
      _listTask[_index].deadline = task.deadline;
      _listTask[_index].color = task.color;

      DbProvider().update('task', task, _listTask[_index].id);
    });

    await _init();
  }

  Widget _setDateText(Duration duration) {
    return Container(
        child: Text(
          _format.format(DateTime.now().add(duration)),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black))),
        height: DATE_LABEL_HEIGHT);
  }

  Widget _setProcListOnDate(int date) {
    return Container(
      height: PROC_LIST_HEIGHT,
      child: ListView.builder(
          itemCount:
              _listProc[date].length == null ? 0 : _listProc[date].length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: _getTaskColor(_listProc[date][index].taskId),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _listProc[date][index].number.toString(),
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        _listProc[date][index].content,
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        _listProc[date][index].time.toString(),
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        DateFormat.yMMMd().format(
                            DateTime.fromMillisecondsSinceEpoch(
                                _listProc[date][index].date)),
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Checkbox(
                            activeColor: Colors.green[300],
                            value: (_listProc[date][index].status ==
                                    Status.DONE.index)
                                ? true
                                : false,
                            onChanged: (bool e) {
                              setState(() {
                                _listProc[date][index].status = e == true
                                    ? Status.DONE.index
                                    : Status.WIP.index;
                                DbProvider().update(
                                    'proc',
                                    _listProc[date][index],
                                    _listProc[date][index].id);
                              });
                            }),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  List<Task> task =
                      await DbProvider().getTask(_listProc[date][index].taskId);
                  setState(() {
                    _edit(task[0], index);
                  });
                },
              ),
            );
          }),
    );
  }

  Color _getTaskColor(int taskId) {
    _listTask.forEach((Task t) {
      if (taskId == t.id) {
        return TaskColor.getTaskColor(t.color);
      }
    });

    return Colors.white;
  }
}
