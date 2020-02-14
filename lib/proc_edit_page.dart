import 'package:flutter/material.dart';

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
    return Container();
  }
}
