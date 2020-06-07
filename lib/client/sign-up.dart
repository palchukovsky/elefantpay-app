import 'sign-in.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../help.dart';
import '../session.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isRequested = false;
  bool _isBusy = false;
  String _error = "";

  String _email = "";
  String _password = "";

  final _formKey = GlobalKey<FormState>();

  _request() async {
    setState(() {
      _isBusy = true;
    });
    final error = await session.register(_email, _password);
    setState(() {
      _error = error;
      _isRequested = true;
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBusy) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return !_isRequested || _error.isNotEmpty
        ? _buildForm(context)
        : _buildResult(context);
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
                'Sign Up Your New Account',
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
                  child: Text('Sign Up'),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Already have an account? '),
                    InkWell(
                      child: Text('Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()));
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

  Widget _buildResult(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              'Your account is almost ready!',
              style: Theme.of(context).textTheme.headline5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Text('Check email ${session.clientEmail} ' +
                  'to confirm it and complete registration.'),
            ),
            InkWell(
              child:
                  Text('Sign In', style: Theme.of(context).textTheme.headline6),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
            Spacer(),
          ],
        ),
      ),
      floatingActionButton: HelpFloatingButton(),
    );
  }
}
