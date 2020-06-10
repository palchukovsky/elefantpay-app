import 'package:flutter/material.dart';
import 'help.dart';
import 'session.dart';
import 'start/sign-in.dart';
import 'start/fields.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: FormRoot(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text('New ultimate mobile wallet'),
            Text('ElefantPay', style: Theme.of(context).textTheme.headline2),
            Text('comming soon', style: Theme.of(context).textTheme.headline4),
            Spacer(),
            Text(
                'Your account ${session.clientEmail} is registered, ' +
                    'be ready to be one of the first customers!',
                textAlign: TextAlign.center),
            Spacer(),
            InkWell(
                child: Text('Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: _signOut),
            Spacer(),
          ])),
      floatingActionButton: HelpFloatingButton(),
    );
  }

  _signOut() {
    session.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInPage()),
        (Route<dynamic> route) => false);
  }
}
