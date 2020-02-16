import 'package:flutter/material.dart';

import 'package:taskbrake/db_provider.dart';
import 'package:taskbrake/ok_cancel_dialog.dart';

class SettingPopupMenuButton extends StatefulWidget {
  @override
  _SettingPopupMenuButtonState createState() => _SettingPopupMenuButtonState();
}

class _SettingPopupMenuButtonState extends State<SettingPopupMenuButton> {
  final List<String> _settingMenu = [
    "Clear database",
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.settings),
      onSelected: (String s) async {
        bool ret = false;
        switch (s) {
          case "Clear database":
            ret = await OkCancelDialog.showOkCancelDialog(
                context, 'Confirmation', 'You are sure to clear the database?');
            break;
          default:
            break;
        }
        //if (ret) {
        await DbProvider().clearDB();
        //}
      },
      itemBuilder: (BuildContext context) {
        return _settingMenu.map((String s) {
          return PopupMenuItem(
            child: Text(s),
            value: s,
          );
        }).toList();
      },
    );
  }
}
