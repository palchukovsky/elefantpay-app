import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend.dart' as backend;
import 'config.dart';
import 'dart:async';

final session = _Session();

abstract class SessionException implements Exception {
  String getMessage();

  factory SessionException([var message]) => _SessionException(message);

  factory SessionException.createGeneral(final http.Response response) {
    final error = backend.Error.fromJson(json.decode(response.body));
    if (error.message == null || error.message == "") {
      return SessionException.createUnexpected(response);
    }
    return SessionException(error.message);
  }

  factory SessionException.createUnexpected(final http.Response response) {
    throw SessionException('Server error, please try again later');
  }

  factory SessionException.createResponseFormatError(
      final http.Response response) {
    return SessionException('Server error, please try again later');
  }

  factory SessionException.createAccessError() {
    return SessionException('Access error');
  }
}

class _SessionException implements SessionException {
  final message;

  _SessionException([this.message]);

  String getMessage() {
    return message;
  }

  String toString() {
    if (message == null) {
      return "Session Exception";
    }
    return 'Session Exception: "$message"';
  }
}

class _Session {
  bool get isAuthed => _authToken != null;
  String authToken() => _authToken;

  bool get isConfirmRequested => _confirmRequest != null;
  DateTime get twoFaCodeSentTime => _twoFaCodeResendCountdown;

  bool get isRegistered => _clientEmail != null && _confirmRequest == null;
  String get clientName => _clientName;
  String get clientEmail => _clientEmail;

  String get error => _error;

  load() async {
    if (_storage != null) {
      return;
    }
    _storage = FlutterSecureStorage();
    await _read();
  }

  Future register(
      final String name, final String email, final String password) async {
    return _handleResponse(
        _post(
            'client', backend.ClientRegistration(name, email, password), false),
        (final http.Response response) {
      switch (response.statusCode) {
        case 201:
          _clientEmail = email;
          _saveCofirmRequest(response);
          return;
        case 409:
          throw SessionException('Email already used');
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future resend2faCode() async {
    return _handleResponse(
        _put(
            'client/credentials/confirmation',
            backend.ClientEmail(_clientEmail),
            false), (final http.Response response) {
      switch (response.statusCode) {
        case 202:
          _saveCofirmRequest(response);
          return;
        case 404: // Provided credentials are not used for any client.
          throw SessionException.createGeneral(response);
        case 409:
          throw SessionException(
              'Account already is confirmed, you may sign-in');
        case 425:
          throw SessionException('Please wait more to send new request');
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future confirm(final String token) async {
    return _handleResponse(
        _post(
            'client/credentials/confirmation',
            backend.CredentialsConfirmation(_confirmRequest, token),
            false), (final http.Response response) {
      switch (response.statusCode) {
        case 200:
          _saveUserInfo(response);
          return;
        case 404:
          throw SessionException(
              'PIN is not valid PIN to confirm email ' + _clientEmail);
        case 409:
          throw SessionException('Email already used');
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future login(final String email, final String password) async {
    return _handleResponse(
        _post(
            'client/login', backend.ClientCredentials(email, password), false),
        (final http.Response response) {
      switch (response.statusCode) {
        case 201:
          _saveUserInfo(response);
          break;
        case 404:
          throw SessionException('Email or password is invalid');
        case 422:
          _saveCofirmRequest(response);
          throw SessionException('Email or password is invalid');
        default:
          throw SessionException.createUnexpected(response);
      }
    });
  }

  Future logout() async {
    _authToken = null;
    _save();
  }

  Future<Map<String, backend.AccountInfo>> requestAccountList() async {
    return _handleResponse(_get('account', true),
        (final http.Response response) {
      switch (response.statusCode) {
        case 200:
          {
            backend.AccountInfoDict result;
            try {
              result =
                  backend.AccountInfoDict.fromJson(json.decode(response.body));
            } on FormatException {
              throw SessionException.createResponseFormatError(response);
            }
            return result.accounts;
          }
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future<backend.AccountDetails> requestAccountDetails(
      final String id, final int from) async {
    return _handleResponse(_get('account/$id?from=$from', true),
        (final http.Response response) {
      switch (response.statusCode) {
        case 200:
          {
            backend.AccountDetails result;
            try {
              result =
                  backend.AccountDetails.fromJson(json.decode(response.body));
            } on FormatException {
              throw SessionException.createResponseFormatError(response);
            }
            return result;
          }
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future addMoney(final String account, final backend.BankCard card,
      final double amount) async {
    return _handleResponse(
        _post('account/$account', backend.AddMoneyAction(amount, card), true),
        (final http.Response response) {
      switch (response.statusCode) {
        case 200:
        case 202:
          return;
        default:
          break;
      }
      throw SessionException.createUnexpected(response);
    });
  }

  Future<Result> _handleResponse<Result>(final Future<http.Response> response,
      final Result Function(http.Response) hander) async {
    final completer = Completer<Result>();
    response.then((final http.Response httpResponse) {
      _saveAuth(httpResponse);
      switch (httpResponse.statusCode) {
        case 400: // The request has invalid parameters.
          completer.completeError(
              SessionException.createGeneral(httpResponse).getMessage());
          return;
        case 403:
          _authToken = null;
          _save();
          completer
              .completeError(SessionException.createAccessError().getMessage());
          return;
      }
      Result result;
      try {
        result = hander(httpResponse);
      } on SessionException catch (ex) {
        completer.completeError(ex.getMessage());
        return;
      }
      completer.complete(result);
    }).catchError((error) => completer.completeError(error.error));
    return completer.future;
  }

  _read() async {
    Map<String, String> vals = await _storage.readAll();
    if (vals['version'] != _version) {
      vals = {};
    }
    _authToken = vals['authToken'];
    _confirmRequest = vals['confirmRequest'];
    _clientName = vals['name'];
    _clientEmail = vals['email'];
    _validate();
  }

  _save() async {
    _validate();
    _storage.deleteAll();
    _writeKey('version', _version);
    _writeKey('authToken', _authToken);
    _writeKey('name', _clientName);
    _writeKey('email', _clientEmail);
    _writeKey('confirmRequest', _confirmRequest);
  }

  _writeKey(final String key, final String value) async {
    if (value == null) {
      return;
    }
    _storage.write(key: key, value: value);
  }

  _validate() {
    if (_clientEmail == null) {
      _clientName = null;
      _authToken = null;
      _confirmRequest = null;
    }
    _headersAuth = Map<String, String>.from(_headers);
    if (_authToken != null) {
      _confirmRequest = null;
      _headersAuth['Authorization'] = 'Bearer $_authToken';
    }
  }

  Future<http.Response> _post(final String method,
      final backend.Request request, final bool isAuthed) async {
    return http.post(config.backendUrl + method,
        headers: _getHeaders(isAuthed), body: jsonEncode(request.toJson()));
  }

  Future<http.Response> _put(final String method, final backend.Request request,
      final bool isAuthed) async {
    return http.put(config.backendUrl + method,
        headers: _getHeaders(isAuthed), body: jsonEncode(request.toJson()));
  }

  Future<http.Response> _get(final String method, final bool isAuthed) async {
    return http.get(config.backendUrl + method, headers: _getHeaders(isAuthed));
  }

  _saveUserInfo(final http.Response response) {
    backend.ClientInfo info;
    try {
      info = backend.ClientInfo.fromJson(json.decode(response.body));
    } on FormatException {
      throw SessionException.createResponseFormatError(response);
    }
    _clientName = info.name;
    _clientEmail = info.email;
    _save();
  }

  _saveCofirmRequest(final http.Response response) {
    try {
      _confirmRequest = backend.CredentialsConfirmationRequest.fromJson(
              json.decode(response.body))
          .confirmation;
    } on FormatException {
      throw SessionException.createResponseFormatError(response);
    }
    _twoFaCodeResendCountdown = DateTime.now().toUtc();
    _save();
  }

  _saveAuth(final http.Response response) {
    final authToken = response.headers['auth-token'];
    if (authToken == null || _authToken == authToken) {
      return;
    }
    _authToken = authToken;
    _save();
  }

  _getHeaders(final bool isAuthed) {
    return !isAuthed ? _headers : _headersAuth;
  }

  static const _headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };
  var _headersAuth = Map<String, String>.from(_headers);

  FlutterSecureStorage _storage;

  static const _version = "1";
  String _authToken;
  String _clientName;
  String _clientEmail;
  String _confirmRequest;
  var _twoFaCodeResendCountdown = DateTime.now().toUtc();
  String _error;
}
