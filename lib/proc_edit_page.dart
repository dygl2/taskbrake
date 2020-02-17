import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

import 'package:taskbrake/proc.dart';

class ProcEditPage extends StatefulWidget {
  Proc _proc;
  Function _onChanged;

  ProcEditPage(this._proc, this._onChanged);

  @override
  _ProcEditPageState createState() =>
      _ProcEditPageState(this._proc, this._onChanged);
}

class _ProcEditPageState extends State<ProcEditPage> {
  Proc _proc;
  Function _onChanged;

  _ProcEditPageState(this._proc, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Proc'),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextField(
                autofocus: false,
                controller: TextEditingController(text: _proc.content),
                decoration: InputDecoration(labelText: 'content'),
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
                onChanged: (text) {
                  _proc.content = text;
                  _onChanged(_proc);
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                autofocus: false,
                controller: TextEditingController(text: _proc.time.toString()),
                decoration: InputDecoration(labelText: 'time(hour)'),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                onChanged: (text) {
                  _proc.time = double.parse(text);
                  _onChanged(_proc);
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: CalendarCarousel<Event>(
                onDayPressed: onDayPressed,
                weekendTextStyle: TextStyle(color: Colors.red),
                height: 420,
                selectedDateTime:
                    DateTime.fromMillisecondsSinceEpoch(_proc.date),
                selectedDayBorderColor: Colors.transparent,
                selectedDayButtonColor: Colors.orangeAccent,
                daysHaveCircularBorder: false,
                todayBorderColor: Colors.blue,
                todayButtonColor: Colors.white,
                todayTextStyle: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() {
      _proc.date = date.millisecondsSinceEpoch;
      _onChanged(_proc);
    });
  }
}
