import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/proc_edit_page.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';

class TaskEditPage extends StatefulWidget {
  Task _task;
  Function _onChanged;

  TaskEditPage(this._task, this._onChanged);

  @override
  _TaskEditPageState createState() =>
      _TaskEditPageState(this._task, this._onChanged);
}

class _TaskEditPageState extends State<TaskEditPage> {
  final Task _task;
  final Function _onChanged;
  List<Proc> _listProc = List<Proc>();
  int _index = 0;
  int _maxNumber = 1;

  _TaskEditPageState(this._task, this._onChanged);

  void _init() async {
    _listProc = await DbProvider().getProcInTask(_task.id);
    if (_listProc.length > 0) {
      _maxNumber = _listProc[_listProc.length - 1].number + 1;
    }

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
        title: Text('Edit Task'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _add();
          }),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextField(
                autofocus: false,
                controller: TextEditingController(text: _task.title),
                decoration: InputDecoration(
                  labelText: "task title",
                ),
                keyboardType: TextInputType.text,
                style: new TextStyle(color: Colors.black),
                onChanged: (text) {
                  _task.title = text;
                  _onChanged(_task);
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: _listProc.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(_listProc[index].id.toString()),
                    onDismissed: (direction) {
                      setState(() {
                        DbProvider().delete('task', _listProc[index].id);
                        _listProc.removeAt(index);
                      });
                      if (direction == DismissDirection.endToStart) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted'),
                          ),
                        );
                      }
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
                              flex: 1,
                              child: Text(
                                _listProc[index].number.toString(),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(_listProc[index].content),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(_listProc[index].time.toString()),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                DateFormat.yMMMd().format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _listProc[index].date)),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Checkbox(
                                  activeColor: Colors.green[300],
                                  value: (_listProc[index].status ==
                                          Status.DONE.index)
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
                            _edit(_listProc[index], _index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _add() {
    setState(() {
      _index = _listProc.length;
      int id = DateTime.now().millisecondsSinceEpoch;
      Proc proc = new Proc(
          id: id,
          taskId: _task.id,
          number: _maxNumber,
          content: "",
          time: 1,
          date: DateTime.now().millisecondsSinceEpoch,
          status: Status.WIP.index);
      DbProvider().insert('proc', proc);
      _listProc.add(proc);
      _maxNumber++;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return ProcEditPage(proc, _onProcChanged);
      }));
    });
  }

  void _edit(Proc proc, int index) {
    setState(() {
      _index = index;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return ProcEditPage(proc, _onProcChanged);
      }));
    });
  }

  void _onProcChanged(Proc proc) {
    setState(() {
      _listProc[_index].id = proc.id;
      _listProc[_index].taskId = proc.taskId;
      _listProc[_index].number = proc.number;
      _listProc[_index].content = proc.content;
      _listProc[_index].time = proc.time;
      _listProc[_index].date = proc.date;
      _listProc[_index].status = proc.status;

      DbProvider().update('proc', proc, _listProc[_index].taskId);
    });
  }

  void _setCheckbox(bool e) {
    setState(() {
      _listProc[_index].status =
          e == true ? Status.DONE.index : Status.WIP.index;
    });
  }
}
