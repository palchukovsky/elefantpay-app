import 'sign-in.dart';
import '../page/money.dart';
import '../session.dart';
import '../help.dart';
import '../fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ConfirmationPage extends StatefulWidget {
  ConfirmationPage({Key key}) : super(key: key);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  static const _pinLength = 5;
  var _isBusy = false;
  String _error;
  String _twofaCodeResendCountDown;
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _token;

  @protected
  void initState() {
    super.initState();
    _check2FaCodeResendAbility();
  }

  @override
  Widget build(final BuildContext context) {
    if (_isBusy) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
        appBar: AppBar(title: Text('New account')),
        body: FormRoot(Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Text('Your account is almost ready!',
                      style: Theme.of(context).textTheme.headline6),
                  const Spacer(),
                  Text(
                      'Check email ${session.clientEmail} ' +
                          'to confirm it and complete registration.',
                      textAlign: TextAlign.center),
                  const Spacer(),
                  if (_error != null) ErrorFormText(_error, context),
                  TextFormField(
                      decoration: InputDecoration(
                          labelText: "Confirmation PIN",
                          hintText: "Enter confirmation PIN from email"),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _token = value,
                      controller: _controller,
                      focusNode: _focusNode,
                      onFieldSubmitted: (term) =>
                          endFocus(context, _focusNode, _request),
                      textAlign: TextAlign.center,
                      maxLength: _pinLength,
                      validator: (input) => input.isEmpty
                          ? 'PIN is required'
                          : input.length != _pinLength
                              ? 'PIN has length $_pinLength digits'
                              : null,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[\\d]"))
                      ]),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                          onPressed: _request, child: const Text("Confirm"))),
                  const Spacer(),
                  Row(children: <Widget>[
                    const Spacer(),
                    const Text('Resend PIN: '),
                    if (_twofaCodeResendCountDown == "")
                      InkWell(
                          child: const Text('Resend',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: _resend2faCode),
                    if (_twofaCodeResendCountDown != "")
                      Text(_twofaCodeResendCountDown),
                    Spacer()
                  ]),
                  const Text(""),
                  Row(children: <Widget>[
                    const Spacer(),
                    const Text('Already confirmed? '),
                    InkWell(
                        child: const Text('Sign In',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()));
                        }),
                    const Spacer()
                  ]),
                  Spacer()
                ]))),
        floatingActionButton: HelpFloatingButton());
  }

  Future<bool> _request() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    setState(() => _isBusy = true);
    _formKey.currentState.save();

    final result = Completer<bool>();
    session.confirm(_token).then((final value) => null).then((value) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MoneyPage()),
          (Route<dynamic> route) => false);
      result.complete(true);
    }).catchError((final error) {
      setState(() {
        _error = error;
        _isBusy = false;
      });
      result.complete(false);
    });

    return result.future;
  }

  _resend2faCode() async {
    setState(() {
      _isBusy = true;
    });

    session.resend2faCode().then((final value) {
      _check2FaCodeResendAbility();
      setState(() {
        _isBusy = false;
        _error = null;
      });
    }).catchError((final error) {
      _check2FaCodeResendAbility();
      setState(() {
        _isBusy = false;
        _error = error;
      });
    });
  }

  _check2FaCodeResendAbility() {
    final now = DateTime.now().toUtc();
    final sentTime = session.twoFaCodeSentTime;
    final nextSendTime = sentTime.add(Duration(minutes: 3));
    final diff = nextSendTime.difference(now);
    if (diff.isNegative) {
      setState(() => _twofaCodeResendCountDown = "");
      return;
    }

    String twoDigits(final int n) {
      if (n >= 10) {
        return "$n";
      }
      return "0$n";
    }

    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));
    final countdown = "after $minutes:$seconds";
    setState(() {
      _twofaCodeResendCountDown = countdown;
    });

    Timer(const Duration(seconds: 1), () {
      _check2FaCodeResendAbility();
    });
  }
}
