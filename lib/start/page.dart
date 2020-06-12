import 'fields.dart';
import '../help.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

@optionalTypeArgs
abstract class StartPageState<T extends StatefulWidget> extends State<T> {
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

  StartPageState(this.title, this.sumitTitle);

  @protected
  get hasError => _error != null;

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
    return buildForm(context);
  }

  @protected
  Widget buildForm(BuildContext context) {
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
                if (_error != null) ErrorFormText(_error, context),
                EmailFormField(
                    controller: _emailController,
                    onSaved: (value) => setState(() => _email = value),
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) =>
                        focusChange(context, _emailFocus, _passwordFocus)),
                buildPasswordFields(
                    context,
                    _passwordController,
                    _passwordFocus,
                    (value) => setState(() => _password = value),
                    _request),
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
      floatingActionButton: HelpFloatingButton(),
    );
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

  _request() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _isBusy = true);
    _formKey.currentState.save();

    final error = await request(_email, _password);
    if (error == null && handleSuccess()) {
      return;
    }
    setState(() {
      _error = error;
      _isBusy = false;
    });
  }
}
