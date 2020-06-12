import 'fields.dart';
import 'sign-in.dart';
import 'page.dart';
import '../session.dart';
import '../help.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends StartPageState<SignUpPage> {
  bool _isRequested = false;

  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final FocusNode _passwordConfirmFocus = FocusNode();

  _SignUpPageState() : super('Sign Up Your New Account', 'Sign Up');

  @override
  Future<String> request(String email, String password) {
    _isRequested = true;
    return session.register(email, password);
  }

  @override
  Widget buildForm(BuildContext context) {
    return !_isRequested || hasError
        ? super.buildForm(context)
        : _buildResult(context);
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
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
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

  @override
  Widget buildPasswordFields(
      BuildContext context,
      TextEditingController passwordController,
      FocusNode passwordFocus,
      FormFieldSetter<String> onSaved,
      void Function() submit) {
    return Column(children: <Widget>[
      PasswordFormField(
          label: 'Password',
          hint: 'Create your password',
          onSaved: onSaved,
          controller: passwordController,
          focusNode: passwordFocus,
          onFieldSubmitted: (term) =>
              focusChange(context, passwordFocus, _passwordConfirmFocus)),
      PasswordFormField(
        controller: _passwordConfirmController,
        label: 'Password confirmation',
        hint: 'Confirm your password',
        validate: (value) => value != passwordController.text
            ? 'Password confirmation does not match'
            : null,
        focusNode: _passwordConfirmFocus,
        onFieldSubmitted: (term) =>
            focusEnd(context, _passwordConfirmFocus, submit),
      ),
    ]);
  }

  @override
  List<Widget> buildExtra(BuildContext context) {
    return <Widget>[
      Text('Already have an account? '),
      InkWell(
          child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignInPage()));
          })
    ];
  }
}
