import 'package:elefantpay/home.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../help.dart';
import '../session.dart';
import 'sign-up.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isBusy = false;
  String _error = "";

  String _email = "";
  String _password = "";

  final _formKey = GlobalKey<FormState>();

  _request() async {
    setState(() {
      _isBusy = true;
    });
    final error = await session.login(_email, _password);
    if (error.isNotEmpty) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image(image: AssetImage('assets/images/logo.jpeg')),
              Text(
                'Sign In to Your Account',
                style: Theme.of(context).textTheme.headline6,
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Your account',
                ),
                validator: (input) {
                  return input.isEmpty
                      ? "Required"
                      : !EmailValidator.validate(input) ? "Wrong format" : null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
                validator: (input) => input.isEmpty ? "Required" : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    _request();
                  },
                  child: Text('Sign In'),
                ),
              ),
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
                      },
                    ),
                  ]),
              Spacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: HelpFloatingButton(),
    );
  }
}
