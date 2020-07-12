import 'package:flutter/material.dart';
import '../help.dart';
import '../session.dart';
import '../navigation.dart';
import '../start/sign-in.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(final BuildContext context) {
    var content;
    if (_isBusy) {
      content = <Widget>[Center(child: CircularProgressIndicator())];
    } else {
      content = <Widget>[
        const Spacer(),
        InkWell(
            child: Text('Logout', style: Theme.of(context).textTheme.headline6),
            onTap: () => _logout()),
        const Spacer()
      ];
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: content)),
        bottomNavigationBar: buildBottomNavigationBar(2, context),
        floatingActionButton: HelpFloatingButton());
  }

  _logout() {
    setState(() => _isBusy = true);
    session.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInPage()),
        (Route<dynamic> route) => false);
  }

  bool _isBusy = false;
}
