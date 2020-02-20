import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskbrake/change_date_dialog.dart';

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
    await _updateProcNumber();

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
        padding: const EdgeInsets.all(8.0),
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
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) async {
                  Proc proc;
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    proc = _listProc.removeAt(oldIndex);

                    _listProc.insert(newIndex, proc);
                  });

                  if (proc != null) {
                    await DbProvider().delete('proc', oldIndex);
                    await DbProvider().insert('proc', proc);
                    await _updateProcNumber();

                    _onChanged(_task);
                  }
                },
                children: List.generate(_listProc.length, (index) {
                  return Dismissible(
                    key: Key(_listProc[index].id.toString()),
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await DbProvider().delete('proc', _listProc[index].id);
                        setState(() {
                          _listProc.removeAt(index);

                          // Todo: of(context) has exception
                          //Scaffold.of(context).showSnackBar(
                          //SnackBar(
                          //content: Text('Deleted'),
                          //),
                          //);
                        });
                        await _updateProcNumber();

                        _onChanged(_task);
                      }
                    },
                    background: Container(
                      color: Colors.greenAccent[50],
                    ),
                    child: Card(
                      key: Key(_listProc[index].id.toString()),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                _listProc[index].number.toString(),
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                _listProc[index].content,
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _listProc[index].time.toString(),
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                DateFormat.yMMMd().format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _listProc[index].date)),
                                style: TextStyle(fontSize: 10.0),
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
                                    onChanged: (bool e) {
                                      setState(() {
                                        _listProc[index].status = e == true
                                            ? Status.DONE.index
                                            : Status.WIP.index;
                                        DbProvider().update(
                                            'proc',
                                            _listProc[index],
                                            _listProc[index].id);

                                        _onChanged(_task);
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _edit(_listProc[index], index);
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: FlatButton(
                  child: Icon(Icons.access_time),
                  onPressed: () async {
                    final _dialog = new ChangeDateDialog();
                    final result = await _dialog.showChangeDateDialog(
                        context, 'Change date', "");

                    if (result != null) {
                      setState(() {
                        for (Proc p in _listProc) {
                          DateTime tmpDate =
                              DateTime.fromMillisecondsSinceEpoch(p.date);
                          Duration tmpDuration = new Duration(days: result);
                          tmpDate = tmpDate.add(tmpDuration);
                          p.date = tmpDate.millisecondsSinceEpoch;

                          DbProvider().update('proc', p, p.id);

                          _onChanged(_task);
                        }
                      });
                    }
                  }),
            ),
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
          time: 1.0,
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

  void _onProcChanged(Proc proc) async {
    setState(() {
      _listProc[_index].id = proc.id;
      _listProc[_index].taskId = proc.taskId;
      _listProc[_index].number = proc.number;
      _listProc[_index].content = proc.content;
      _listProc[_index].time = proc.time;
      _listProc[_index].date = proc.date;
      _listProc[_index].status = proc.status;

      // update task deadline
      int latestDate = DateTime.now().millisecondsSinceEpoch;
      _listProc.forEach((Proc p) {
        if (latestDate < p.date) {
          latestDate = p.date;
        }
      });

      _task.deadline = latestDate;
    });

    await DbProvider().update('proc', proc, _listProc[_index].id);
    await DbProvider().update('task', _task, _task.id);
  }

  Future<void> _updateProcNumber() async {
    int num = 1;
    _listProc.forEach((Proc p) {
      p.number = num;
      DbProvider().update('proc', p, p.id);
      num++;
    });
  }
}
