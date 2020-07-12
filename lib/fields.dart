import 'package:flutter/material.dart';

class FormRoot extends Center {
  FormRoot(Widget child)
      : super(
            child: Padding(padding: const EdgeInsets.all(56.0), child: child));
}

class ErrorFormText extends Padding {
  ErrorFormText(final String error, BuildContext context)
      : super(
            padding: const EdgeInsets.all(16.0),
            child: Text(error,
                style: TextStyle(color: Theme.of(context).errorColor),
                textAlign: TextAlign.center));
}

changeFocus(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

endFocus(BuildContext context, FocusNode currentFocus,
    Future<bool> Function() submit) async {
  currentFocus.unfocus();
  submit().then((final bool value) {
    if (!value) {
      currentFocus.requestFocus();
    }
  });
}
