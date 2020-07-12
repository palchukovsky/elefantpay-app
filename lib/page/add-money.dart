import 'package:elefantpay/backend.dart';
import 'package:flutter/material.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'dart:async';
import '../backend.dart';
import '../fields.dart';
import '../help.dart';
import '../session.dart';
import 'money.dart';

class AddMoneyPage extends StatefulWidget {
  AddMoneyPage(this._account, this._balance, this._currency, {Key key})
      : super(key: key);

  @override
  _AddMoneyPageState createState() =>
      _AddMoneyPageState(_account, _balance, _currency);

  final String _account;
  final String _balance;
  final String _currency;
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  _AddMoneyPageState(this._account, this._balance, this._currency);

  @override
  Widget build(final BuildContext context) {
    if (_isBusy) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final content = <Widget>[
      Spacer(),
      if (_error != null) ErrorFormText(_error, context),
      Spacer(),
      TextFormField(
          decoration:
              InputDecoration(hintText: 'Enter amount', labelText: _currency),
          validator: (input) =>
              input.isEmpty || double.parse(input.replaceAll(',', '')) <= 0
                  ? 'Amount required'
                  : null,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsFormatter(allowFraction: true)],
          onSaved: (value) => _amount = double.parse(value.replaceAll(',', '')),
          controller: _amountController,
          focusNode: _amountFocus,
          onFieldSubmitted: (v) =>
              changeFocus(context, _amountFocus, _numberFocus)),
      Text('Actual balance: $_balance $_currency'),
      Spacer(),
      TextFormField(
          decoration: const InputDecoration(
              hintText: 'Enter card number', labelText: 'Card number'),
          validator: (input) =>
              input.replaceAll(' ', '').isEmpty ? 'Card number required' : null,
          keyboardType: TextInputType.number,
          inputFormatters: [CreditCardFormatter()],
          maxLength: 16,
          onSaved: (value) => _number = int.parse(value.replaceAll(' ', '')),
          controller: _numberController,
          focusNode: _numberFocus,
          onFieldSubmitted: (v) =>
              changeFocus(context, _numberFocus, _monthFocus)),
      DropdownButton<int>(
          value: 1,
          items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
              .map<DropdownMenuItem<int>>((final int value) {
            return DropdownMenuItem<int>(value: value, child: Text("$value"));
          }).toList(),
          onChanged: (value) => _month = value,
          focusNode: _monthFocus),
      DropdownButton<int>(
          value: 2023,
          items: <int>[2020, 2021, 2022, 2023, 2024, 2025, 2026]
              .map<DropdownMenuItem<int>>((final int value) {
            return DropdownMenuItem<int>(value: value, child: Text("$value"));
          }).toList(),
          onChanged: (value) => _year = value),
      Spacer(),
      RaisedButton(onPressed: () => _submit(context), child: Text('Add money')),
      Spacer()
    ];

    return Scaffold(
        appBar: AppBar(title: Text('Add money')),
        body: FormRoot(Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: content))),
        floatingActionButton: HelpFloatingButton());
  }

  Future<bool> _submit(final BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    setState(() => _isBusy = true);
    _formKey.currentState.save();

    final result = Completer<bool>();
    session
        .addMoney(_account, BankCard(_number, _month, _year, _cvc), _amount)
        .then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MoneyPage(account: _account)));
      result.complete(true);
    }).catchError((error) {
      setState(() {
        _error = error;
        _isBusy = false;
      });
      result.complete(false);
    });

    return result.future;
  }

  final String _account;
  final String _balance;
  final String _currency;

  String _error;
  bool _isBusy = false;

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();

  final _numberController = TextEditingController();
  final _numberFocus = FocusNode();

  final _monthFocus = FocusNode();

  var _amount = .0;
  var _number = 0;
  var _month = 0;
  var _year = 0;
  var _cvc = '';
}
