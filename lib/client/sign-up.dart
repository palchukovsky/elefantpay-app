import 'fields.dart';
import 'sign-in.dart';
import '../session.dart';
import '../help.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isRequested = false;
  bool _isBusy = false;
  String _error;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();

  String _email;
  String _password;

  _request() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _isBusy = true;
    });
    _formKey.currentState.save();

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
    return !_isRequested || _error != null
        ? _buildForm(context)
        : _buildResult(context);
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
                Text('Sign Up Your New Account',
                    style: Theme.of(context).textTheme.headline6),
                if (_error != null) ErrorFormText(_error, context),
                EmailFormField(
                    onSaved: (value) => setState(() => _email = value),
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) =>
                        focusChange(context, _emailFocus, _passwordFocus)),
                PasswordFormField(
                    label: 'Password',
                    hint: 'Create your password',
                    onSaved: (value) => setState(() => _password = value),
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (term) => focusChange(
                        context, _passwordFocus, _passwordConfirmFocus)),
                PasswordFormField(
                  label: 'Password confirmation',
                  hint: 'Confirm your password',
                  validate: (value) => value != _passwordController.text
                      ? 'Password confirmation does not match'
                      : null,
                  focusNode: _passwordConfirmFocus,
                  onFieldSubmitted: (term) =>
                      focusEnd(context, _passwordConfirmFocus, _request),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                        onPressed: _request, child: Text('Sign Up'))),
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
                          })
                    ]),
                Spacer(),
              ]))),
      floatingActionButton: HelpFloatingButton(),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New account')),
      body: FormRoot(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text('Your account is almost ready!',
                style: Theme.of(context).textTheme.headline5),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Text(
                    'Check email ${session.clientEmail} ' +
                        'to confirm it and complete registration.',
                    textAlign: TextAlign.center)),
            InkWell(
                child: Text('Sign In',
                    style: Theme.of(context).textTheme.headline6),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInPage()));
                }),
            Spacer(),
          ])),
      floatingActionButton: HelpFloatingButton(),
    );
  }
}
