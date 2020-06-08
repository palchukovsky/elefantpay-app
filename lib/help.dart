import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

requestHelp() async {
  const url = 'https://elefantpay.com/#contacts';
  if (await canLaunch(url)) {
    launch(url);
  }
}

class HelpFloatingButton extends FloatingActionButton {
  HelpFloatingButton()
      : super(onPressed: requestHelp, tooltip: 'Help', child: Icon(Icons.help));
}
