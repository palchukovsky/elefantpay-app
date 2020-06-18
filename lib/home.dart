import 'package:flutter/material.dart';
import 'help.dart';
import 'session.dart';
import 'utils.dart';
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
      appBar: AppBar(title: Text('Welcome, ${session.clientName}')),
      body: FormRoot(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text('New ultimate mobile wallet'),
            Text('ElefantPay', style: Theme.of(context).textTheme.headline2),
            Text('coming soon', style: Theme.of(context).textTheme.headline4),
            Spacer(),
            Text('Your account ${session.clientEmail} is registered.',
                textAlign: TextAlign.center),
            Text('Get ready to become one of the first customers!',
                textAlign: TextAlign.center),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('For investment: '),
                  InkWell(
                      child: Text('invest@elefantpay.com',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => writeEmail('invest@elefantpay.com'))
                ]),
            Text(''),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('For any questions: '),
                  InkWell(
                      child: Text('info@elefantpay.com',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => writeEmail('info@elefantpay.com'))
                ]),
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
