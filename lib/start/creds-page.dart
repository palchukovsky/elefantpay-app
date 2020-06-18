import 'fields.dart';
import '../help.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

@optionalTypeArgs
abstract class CredsPageState<T extends StatefulWidget> extends State<T> {
  final String title;
  final String sumitTitle;

  bool _isBusy = false;
  bool _isKeyboardVisible = false;
  String _error;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String _email;
  String _password;

  CredsPageState(this.title, this.sumitTitle);

  @protected
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
        onChange: (final bool isVisible) =>
            setState(() => _isKeyboardVisible = isVisible));
  }

  @override
  Widget build(BuildContext context) {
    if (_isBusy) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
        body: FormRoot(Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  if (!_isKeyboardVisible) Logo(),
                  Text(title, style: Theme.of(context).textTheme.headline6),
                  if (_error != null) buildError(context),
                  buildAccountFields(context, _emailFocus),
                  buildPasswordFields(context, _passwordController,
                      _passwordFocus, (value) => _password = value, _request),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                          onPressed: _request, child: Text(sumitTitle))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: buildExtra(context)),
                  Spacer(),
                ]))),
        floatingActionButton: HelpFloatingButton());
  }

  @protected
  Widget buildError(BuildContext context) {
    return ErrorFormText(_error, context);
  }

  @protected
  Widget buildAccountFields(BuildContext context, FocusNode emailFocus) {
    return EmailFormField(
        controller: _emailController,
        onSaved: (value) => _email = value,
        focusNode: emailFocus,
        onFieldSubmitted: (term) =>
            focusChange(context, emailFocus, _passwordFocus));
  }

  @protected
  Widget buildPasswordFields(
      BuildContext context,
      TextEditingController passwordController,
      FocusNode passwordFocus,
      FormFieldSetter<String> onSaved,
      void Function() submit);

  @protected
  List<Widget> buildExtra(BuildContext context);

  @protected
  Future<String> request(String email, String password);

  @protected
  bool handleSuccess() => false;

  Future<bool> _request() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    setState(() => _isBusy = true);
    _formKey.currentState.save();

    final error = await request(_email, _password);
    if (error == null && handleSuccess()) {
      return true;
    }
    setState(() {
      _error = error;
      _isBusy = false;
    });
    return false;
  }
}
