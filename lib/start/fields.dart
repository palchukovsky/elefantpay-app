import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormRoot extends Center {
  FormRoot(Widget child)
      : super(
            child: Padding(padding: const EdgeInsets.all(56.0), child: child));
}

class Logo extends Padding {
  Logo({final FormFieldSetter<String> onSaved})
      : super(
            padding: EdgeInsets.all(32.0),
            child: Image(image: AssetImage('assets/images/screen.png')));
}

class EmailFormField extends TextFormField {
  EmailFormField(
      {final FormFieldSetter<String> onSaved,
      @required final TextEditingController controller,
      final FocusNode focusNode,
      final ValueChanged<String> onFieldSubmitted})
      : super(
            decoration: const InputDecoration(
                hintText: 'Enter your email', labelText: 'Your account'),
            validator: (input) => input.isEmpty
                ? 'Email required'
                : !EmailValidator.validate(input.trim())
                    ? 'Wrong email format'
                    : null,
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) => onSaved(value.trim()),
            controller: controller,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted);
}

class PasswordFormField extends TextFormField {
  PasswordFormField(
      {@required final String label,
      @required final String hint,
      final FormFieldSetter<String> onSaved,
      final FormFieldValidator<String> validate,
      @required final TextEditingController controller,
      final FocusNode focusNode,
      final ValueChanged<String> onFieldSubmitted})
      : super(
            controller: controller,
            focusNode: focusNode,
            obscureText: true,
            decoration: InputDecoration(hintText: hint, labelText: label),
            validator: (input) {
              if (input.isEmpty) {
                return label + ' required';
              }
              if (validate != null) {
                return validate(input);
              }
              return input.length <= 4
                  ? 'Password must have at least 5 characters'
                  : null;
            },
            keyboardType: TextInputType.visiblePassword,
            onSaved: onSaved,
            onFieldSubmitted: onFieldSubmitted);
}

focusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

focusEnd(BuildContext context, FocusNode currentFocus,
    Future<bool> Function() submit) async {
  currentFocus.unfocus();
  submit().then((final bool value) {
    if (!value) {
      currentFocus.requestFocus();
    }
  });
}
