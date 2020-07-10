import 'start/sign-up.dart';
import 'start/sign-in.dart';
import 'start/confirmation.dart';
import 'session.dart';
import 'config.dart';
import 'page/money.dart';
import 'package:flutter/material.dart';

void runTheApp(final Config newConfig) {
  config = newConfig;
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
              home = !session.isConfirmRequested
                  ? SignUpPage()
                  : ConfirmationPage();
            } else if (!session.isAuthed) {
              home = SignInPage();
            } else {
              home = MoneyPage();
            }
            break;
        }
        return MaterialApp(
          title: 'Elefantpay',
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
