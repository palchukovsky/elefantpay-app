import 'sign-in.dart';
import 'confirmation.dart';
import 'creds-page.dart';
import 'fields.dart';
import '../fields.dart';
import '../session.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends CredsPageState<SignUpPage> {
  String _name;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final FocusNode _passwordConfirmFocus = FocusNode();

  _SignUpPageState() : super('Create Your New Account', 'Sign Up');

  @override
  Future<void> request(String email, String password) {
    return session.register(_name, email, password);
  }

  @override
  bool handleSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ConfirmationPage()),
        (Route<dynamic> route) => false);
    return true;
  }

  @protected
  Widget buildAccountFields(BuildContext context, FocusNode emailFocus) {
    return Column(children: <Widget>[
      TextFormField(
          decoration: const InputDecoration(
              hintText: 'Enter your name', labelText: 'Your name'),
          validator: (input) => input.isEmpty ? 'Name required' : null,
          keyboardType: TextInputType.text,
          onSaved: (value) => _name = value.trim(),
          controller: _nameController,
          focusNode: _nameFocus,
          onFieldSubmitted: (term) =>
              changeFocus(context, _nameFocus, emailFocus)),
      super.buildAccountFields(context, emailFocus)
    ]);
  }

  @override
  Widget buildPasswordFields(
      BuildContext context,
      TextEditingController passwordController,
      FocusNode passwordFocus,
      FormFieldSetter<String> onSaved,
      Future<bool> Function() submit) {
    return Column(children: <Widget>[
      PasswordFormField(
          label: 'Password',
          hint: 'Create your password',
          onSaved: onSaved,
          controller: passwordController,
          focusNode: passwordFocus,
          onFieldSubmitted: (term) =>
              changeFocus(context, passwordFocus, _passwordConfirmFocus)),
      PasswordFormField(
          controller: _passwordConfirmController,
          label: 'Password confirmation',
          hint: 'Confirm your password',
          validate: (value) => value != passwordController.text
              ? 'Password confirmation does not match'
              : null,
          focusNode: _passwordConfirmFocus,
          onFieldSubmitted: (term) =>
              endFocus(context, _passwordConfirmFocus, submit))
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
