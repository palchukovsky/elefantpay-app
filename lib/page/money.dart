import 'package:flutter/material.dart';
import '../help.dart';
import '../session.dart';
import '../backend.dart';
import '../fields.dart';

class MoneyPage extends StatefulWidget {
  MoneyPage({Key key}) : super(key: key);

  @override
  _MoneyPageState createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  @protected
  void initState() {
    super.initState();

    session.requestAccountList().then((final accounts) {
      if (accounts.length == 0) {
        setState(() {
          _details = null;
          _error = 'No accounts found';
        });
        return;
      }
      _revision = 0;
      final accId = accounts.keys.first;
      session
          .requestAccountDetails(accId, _revision)
          .then((details) => setState(() {
                _details = details;
                _error = null;
              }))
          .catchError((error) => setState(() => _error = error));
    }).catchError((error) => setState(() => _error = error));
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      if (_error != null) {
        return Scaffold(body: Center(child: ErrorFormText(_error, context)));
      }
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var actions = <Widget>[];
    _details.history.forEach((v) {
      actions.add(Text('${v.time}: ${v.value} - ${v.subject}'));
    });
    final details = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: actions);

    return Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              if (_error != null) ErrorFormText(_error, context),
              Text('${_details.balance} ${_details.currency}',
                  style: Theme.of(context).textTheme.headline2),
              details
            ])),
        floatingActionButton: HelpFloatingButton());
  }

  AccountDetails _details;
  String _error;
  int _revision = 0;
}
