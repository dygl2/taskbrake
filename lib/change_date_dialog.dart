import 'package:flutter/material.dart';

class ChangeDateDialog extends StatelessWidget {
  TextEditingController _textController = TextEditingController();

  showChangeDateDialog(BuildContext context, String title, String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            controller: _textController,
            decoration: InputDecoration(hintText: 'how many days?'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () =>
                  Navigator.pop(context, int.parse(_textController.text)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
