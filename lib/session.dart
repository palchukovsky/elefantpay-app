import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend.dart' as backend;

final session = _Session();

class _Session {
  FlutterSecureStorage _storage;

  static const _version = "1";
  String _authToken;
  String _clientEmail;
  String _confirmRequest;

  bool get isAuthed => _authToken != null;
  String authToken() => _authToken;

  bool get isConfirmRequested => _confirmRequest != null;

  bool get isRegistered => _clientEmail != null && _confirmRequest == null;
  String get clientEmail => _clientEmail;

  load() async {
    if (_storage != null) {
      return;
    }
    _storage = FlutterSecureStorage();
    await _read();
  }

  _read() async {
    Map<String, String> vals = await _storage.readAll();
    if (vals['authToken'] != _version) {
      vals = {};
    }
    _authToken = vals['authToken'];
    _confirmRequest = vals['confirmRequest'];
    _clientEmail = vals['email'];
    _validate();
  }

  _save() async {
    _validate();
    _storage.deleteAll();
    _writeKey('version', _version);
    _writeKey('authToken', _authToken);
    _writeKey('email', _clientEmail);
    _writeKey('confirmRequest', _confirmRequest);
    _read();
  }

  _writeKey(String key, String value) async {
    if (value == null) {
      return;
    }
    _storage.write(key: key, value: value);
  }

  _validate() {
    if (_clientEmail == null) {
      _authToken = null;
      _confirmRequest = null;
    }
  }

  Future<String> register(String email, String password) async {
    _clientEmail = null;
    _confirmRequest = null;
    _save();

    final response =
        await post('client', backend.ClientCredentials(email, password));
    switch (response.statusCode) {
      case 201:
        _clientEmail = email;
        _confirmRequest = backend.CredentialsConfirmationRequest.fromJson(
                json.decode(response.body))
            .confirmation;
        _save();
        return null;
      case 400: // The request has invalid parameters.
        return _decodeError(response);
      case 409:
        return 'Email already used';
    }
    return _decodeUnexpectedError(response);
  }

  Future<String> login(String email, String password) async {
    _clientEmail = email;
    _authToken = "2";
    _save();
    return null;
  }

  logout() async {
    _authToken = null;
    _save();
    return null;
  }

  String _decodeError(http.Response response) {
    final error = backend.Error.fromJson(json.decode(response.body));
    if (error.message == null || error.message == "") {
      return _decodeUnexpectedError(response);
    }
    return error.message;
  }

  String _decodeUnexpectedError(http.Response response) {
    return 'Server error, please try again later';
  }

  Future<http.Response> post(
      final String method, final backend.Request request) {
    return http.post('https://api-dev.elefantpay.com/' + method,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(request.toJson()));
  }
}
