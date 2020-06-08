import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormRoot extends Center {
  FormRoot(Widget child)
      : super(
            child: Padding(padding: const EdgeInsets.all(16.0), child: child));
}

class Logo extends Padding {
  Logo({final FormFieldSetter<String> onSaved})
      : super(
            padding: const EdgeInsets.all(32.0),
            child: Image(image: AssetImage('assets/images/logo.jpeg')));
}

class EmailFormField extends TextFormField {
  EmailFormField(
      {final FormFieldSetter<String> onSaved,
      final TextEditingController controller,
      final FocusNode focusNode,
      final ValueChanged<String> onFieldSubmitted})
      : super(
            decoration: const InputDecoration(
                hintText: 'Enter your email', labelText: 'Your account'),
            autofocus: true,
            validator: (input) => input.isEmpty
                ? 'Email required'
                : !EmailValidator.validate(input) ? 'Wrong email format' : null,
            inputFormatters: [BlacklistingTextInputFormatter(RegExp("[ ]"))],
            onSaved: onSaved,
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
      final TextEditingController controller,
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
                  ? 'Password must have at least 4 characters'
                  : null;
            },
            onSaved: onSaved,
            onFieldSubmitted: onFieldSubmitted);
}

class ErrorFormText extends Padding {
  ErrorFormText(final String error, BuildContext context)
      : super(
            padding: const EdgeInsets.all(16.0),
            child: Text(error,
                style: TextStyle(color: Theme.of(context).errorColor)));
}

focusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

focusEnd(BuildContext context, FocusNode currentFocus, void Function() submit) {
  currentFocus.unfocus();
  submit();
}
