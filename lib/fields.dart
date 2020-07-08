import 'package:flutter/material.dart';

class ErrorFormText extends Padding {
  ErrorFormText(final String error, BuildContext context)
      : super(
            padding: const EdgeInsets.all(16.0),
            child: Text(error,
                style: TextStyle(color: Theme.of(context).errorColor),
                textAlign: TextAlign.center));
}
