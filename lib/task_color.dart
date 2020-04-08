import 'package:flutter/material.dart';

class TaskColor {
  static Color white = Colors.white;
  static Color blue = Colors.lightBlue;
  static Color green = Colors.lightGreen;
  static Color orange = Colors.orange;
  static Color yellow = Colors.yellow;

  static Color getTaskColor(int index) {
    switch (index) {
      case 0:
        return white;
      case 1:
        return blue;
      case 2:
        return green;
      case 3:
        return orange;
      case 4:
        return yellow;
    }
  }
}
