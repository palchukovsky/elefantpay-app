import 'sign-in.dart';
import 'confirmation.dart';
import 'creds-page.dart';
import 'fields.dart';
import '../session.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends CredsPageState<SignUpPage> {
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final FocusNode _passwordConfirmFocus = FocusNode();

  _SignUpPageState() : super('Create Your New Account', 'Sign Up');

  @override
  Future<String> request(String email, String password) {
    return session.register(email, password);
  }

  @override
  bool handleSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ConfirmationPage()),
        (Route<dynamic> route) => false);
    return true;
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
              focusEnd(context, _passwordConfirmFocus, submit))
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
