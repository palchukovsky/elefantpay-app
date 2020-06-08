import 'sign-up.dart';
import 'fields.dart';
import '../help.dart';
import '../session.dart';
import 'package:elefantpay/home.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isBusy = false;
  String _error;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String _email;
  String _password;

  final _formKey = GlobalKey<FormState>();

  _request() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _isBusy = true;
    });
    _formKey.currentState.save();

    final error = await session.login(_email, _password);
    if (error != null) {
      setState(() {
        _error = error;
        _isBusy = false;
      });
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isBusy) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      body: FormRoot(Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                Logo(),
                Text('Sign In to Your Account',
                    style: Theme.of(context).textTheme.headline6),
                if (_error != null) ErrorFormText(_error, context),
                EmailFormField(
                    onSaved: (value) => setState(() => _email = value),
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) =>
                        focusChange(context, _emailFocus, _passwordFocus)),
                PasswordFormField(
                    label: 'Password',
                    hint: 'Enter your password',
                    onSaved: (value) => setState(() => _password = value),
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (term) =>
                        focusEnd(context, _passwordFocus, _request)),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                        onPressed: _request, child: Text('Sign In'))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Do not have an account? '),
                      InkWell(
                          child: Text('Sign Up',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                          })
                    ]),
                Spacer(),
              ]))),
      floatingActionButton: HelpFloatingButton(),
    );
  }
}
