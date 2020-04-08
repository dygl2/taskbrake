import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:taskbrake/data.dart';
import 'package:taskbrake/task.dart';
import 'package:taskbrake/proc.dart';

class DbProvider {
  static Database _db;
  static DbProvider _cache = DbProvider._internal();
  final _format = DateFormat('yyyy-MM-dd', 'ja');
  String path = "";

  factory DbProvider() {
    return _cache;
  }
  DbProvider._internal();

  Future<Database> get database async {
    if (_db == null) {
      //dbDir = await getDatabasesPath();
      Directory dbDir = await getExternalStorageDirectory();
      path = join(dbDir.path, "taskbrake.db");

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database newDb, int version) {
          newDb.execute("""
              CREATE TABLE task
                (
                  id INTEGER PRIMARY KEY,
                  title TEXT,
                  status INTEGER,
                  deadline INTEGER,
                  color INTEGER  
                )
              """);
          newDb.execute("""
              CREATE TABLE proc
                (
                  id INTEGER PRIMARY KEY,
                  taskId INTEGER,
                  number INTEGER,
                  content TEXT,
                  time REAL,
                  date INTEGER,
                  status INTEGER,
                  FOREIGN KEY (taskId) REFERENCES task(id) 
                )
              """);
        },
      );
    }

    return _db;
  }

  Future<void> clearDB() async {
    deleteDatabase(path);
  }

  Future<int> insert(String tableName, Data data) async {
    return await _db.insert(tableName, data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(String tableName, int index) async {
    await _db.delete(tableName, where: 'id = ?', whereArgs: [index]);
  }

  Future<void> update(String tableName, Data data, int index) async {
    await _db
        .update(tableName, data.toMap(), where: 'id = ?', whereArgs: [index]);
  }

  Future<List<Task>> getTask(int index) async {
    List<Map<String, dynamic>> maps =
        await _db.query('task', where: 'id = ?', whereArgs: [index]);
    return List.generate(maps.length, (i) {
      return Task(
          id: maps[i]['id'],
          title: maps[i]['title'],
          status: maps[i]['status'],
          deadline: maps[i]['deadline'],
          color: maps[i]['color']);
    });
  }

  Future<List<Task>> getTaskAll() async {
    // query sorted todo list in ascending order
    List<Map<String, dynamic>> maps = await _db.query('task');
    return List.generate(maps.length, (i) {
      return Task(
          id: maps[i]['id'],
          title: maps[i]['title'],
          status: maps[i]['status'],
          deadline: maps[i]['deadline'],
          color: maps[i]['color']);
    });
  }

  Future<List<Proc>> getProc(int index) async {
    List<Map<String, dynamic>> maps =
        await _db.query('proc', where: 'id = ?', whereArgs: [index]);
    return List.generate(maps.length, (i) {
      return Proc(
          id: maps[i]['id'],
          taskId: maps[i]['taskId'],
          number: maps[i]['number'],
          content: maps[i]['content'],
          time: maps[i]['time'],
          date: maps[i]['date'],
          status: maps[i]['status']);
    });
  }

  Future<List<Proc>> getProcInTask(int taskId) async {
    // query sorted todo list in ascending order
    List<Map<String, dynamic>> maps = await _db.query('proc',
        where: 'taskId = ?', whereArgs: [taskId], orderBy: 'number ASC');
    return List.generate(maps.length, (i) {
      return Proc(
          id: maps[i]['id'],
          taskId: maps[i]['taskId'],
          number: maps[i]['number'],
          content: maps[i]['content'],
          time: maps[i]['time'],
          date: maps[i]['date'],
          status: maps[i]['status']);
    });
  }

  Future<List<Proc>> getProcOnDate(int date) async {
    DateTime tmpDate = DateTime.fromMillisecondsSinceEpoch(date);
    int fromDate =
        DateTime.parse(_format.format(tmpDate)).millisecondsSinceEpoch;
    int toDate = DateTime.parse(_format.format(tmpDate.add(Duration(days: 1))))
        .millisecondsSinceEpoch;
    List<Map<String, dynamic>> maps = await _db.rawQuery("select * from proc " +
        "where date>=" +
        fromDate.toString() +
        " and date<" +
        toDate.toString());
    return List.generate(maps.length, (i) {
      return Proc(
          id: maps[i]['id'],
          taskId: maps[i]['taskId'],
          number: maps[i]['number'],
          content: maps[i]['content'],
          time: maps[i]['time'],
          date: maps[i]['date'],
          status: maps[i]['status']);
    });
  }
}
