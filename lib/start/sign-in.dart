import 'sign-up.dart';
import 'confirmation.dart';
import 'fields.dart';
import 'creds-page.dart';
import '../session.dart';
import '../page/money.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends CredsPageState<SignInPage> {
  _SignInPageState() : super('Sign In to Your Account', 'Sign In');

  @override
  Future<void> request(String email, String password) {
    return session.login(email, password);
  }

  @override
  bool handleSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MoneyPage()),
        (Route<dynamic> route) => false);
    return true;
  }

  @protected
  Widget buildError(BuildContext context) {
    if (!session.isConfirmRequested) {
      return super.buildError(context);
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          super.buildError(context),
          InkWell(
              child: Text('Confirm ' + session.clientEmail,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmationPage()));
              })
        ]);
  }

  @override
  Widget buildPasswordFields(
      BuildContext context,
      TextEditingController passwordController,
      FocusNode passwordFocus,
      FormFieldSetter<String> onSaved,
      void Function() submit) {
    return PasswordFormField(
        controller: passwordController,
        label: 'Password',
        hint: 'Enter your password',
        onSaved: onSaved,
        focusNode: passwordFocus,
        onFieldSubmitted: (term) => focusEnd(context, passwordFocus, submit));
  }

  @override
  List<Widget> buildExtra(BuildContext context) {
    return <Widget>[
      Text('Do not have an account? '),
      InkWell(
          child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignUpPage()));
          })
    ];
  }
}
