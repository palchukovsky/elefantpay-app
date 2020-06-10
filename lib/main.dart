import 'start/sign-up.dart';
import 'start/sign-in.dart';
import 'package:flutter/material.dart';
import 'session.dart';
import 'home.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: session.load(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        Widget home;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            home = Scaffold(body: Center(child: CircularProgressIndicator()));
            break;
          default:
            if (!session.isRegistered) {
              home = SignUpPage();
            } else if (!session.isAuthed) {
              home = SignInPage();
            } else {
              home = HomePage();
            }
            break;
        }
        return MaterialApp(
          title: 'ElefantPay',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: home,
        );
      },
    );
  }
}
