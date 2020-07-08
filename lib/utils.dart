import 'start/sign-in.dart';
import 'session.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

writeEmail(String address) async {
  address = 'mailto:' + address;
  if (await canLaunch(address)) {
    launch(address);
  }
}

signOut(final BuildContext context) {
  session.logout();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInPage()),
      (Route<dynamic> route) => false);
}
