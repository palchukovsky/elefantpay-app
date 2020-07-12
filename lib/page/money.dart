import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../help.dart';
import '../session.dart';
import '../backend.dart';
import '../fields.dart';
import '../navigation.dart';
import 'add-money.dart';

class MoneyPage extends StatefulWidget {
  MoneyPage({final Key key, final String account})
      : _account = account,
        super(key: key);

  @override
  _MoneyPageState createState() => _MoneyPageState(account: _account);

  final String _account;
}

class _MoneyPageState extends State<MoneyPage> {
  _MoneyPageState({final String account}) : _account = account;

  @protected
  void initState() {
    super.initState();

    if (_account == null) {
      session.requestAccountList().then((final accounts) {
        if (accounts.isEmpty) {
          setState(() {
            _account = null;
            _details = null;
            _error = 'No accounts found';
          });
          return;
        }
        _account = accounts.keys.first;
        _requestAccountDetails();
      }).catchError((error) => setState(() => _error = error));
    } else {
      _requestAccountDetails();
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (_details == null) {
      if (_error != null) {
        return Scaffold(body: Center(child: ErrorFormText(_error, context)));
      }
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final balance = _moneyValueFormat.format(_details.balance);

    final actions = <TableRow>[];
    _details.history.forEach((v) {
      actions.add(_buildAction(v, context));
    });

    return Scaffold(
        appBar: AppBar(title: Text('Money')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              if (_error != null) ErrorFormText(_error, context),
              Text('$balance ${_details.currency}',
                  style: Theme.of(context).textTheme.headline4),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 5.0),
                  child: RaisedButton(
                      onPressed: () => _addMoney(context),
                      child: const Text('Add money'))),
              Table(children: actions, columnWidths: <int, TableColumnWidth>{
                1: FlexColumnWidth(0.3)
              }),
              Spacer()
            ])),
        bottomNavigationBar: buildBottomNavigationBar(0, context),
        floatingActionButton: HelpFloatingButton());
  }

  TableRow _buildAction(
      final AccountAction action, final BuildContext context) {
    final subject =
        "${action.subject[0].toUpperCase()}${action.subject.substring(1)}";
    return TableRow(children: [
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                child: Text(subject,
                    style: Theme.of(context).textTheme.headline6)),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                child: Text(
                    _timeFormat.format(action.time) +
                        ", " +
                        _dateFormat.format(action.time),
                    style: Theme.of(context).textTheme.subtitle1))
          ]),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                child: Text(_moneyValueFormat.format(action.value),
                    style: Theme.of(context).textTheme.headline6))
          ])
    ]);
  }

  _addMoney(final BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddMoneyPage(
                _account,
                _moneyValueFormat.format(_details.balance),
                _details.currency)));
  }

  _requestAccountDetails() {
    session
        .requestAccountDetails(
            _account, _details == null ? 0 : _details.revision)
        .then((details) => setState(() {
              if (details != null) {
                _details = details;
              }
              _error = null;
            }))
        .catchError((error) => setState(() => _error = error));
  }

  String _account;
  AccountDetails _details;
  String _error;

  final _moneyValueFormat = NumberFormat('#,##0.00', 'en_EN');
  final _dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final _timeFormat = DateFormat("Hm");
}
