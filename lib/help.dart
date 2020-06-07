import 'package:flutter/material.dart';

requestHelp() {}

class HelpFloatingButton extends FloatingActionButton {
  HelpFloatingButton()
      : super(
          onPressed: requestHelp(),
          tooltip: 'Help',
          child: Icon(Icons.help),
        );
}
