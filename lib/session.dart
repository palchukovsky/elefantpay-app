import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final session = _Session();

class _Session {
  FlutterSecureStorage _storage;

  String _authToken = '';
  String _clientId = '';
  String _clientEmail = '';

  bool get isAuthed => _authToken.isNotEmpty;
  String authToken() => _authToken;

  bool get isRegistered => _clientId.isNotEmpty;
  String get clientId => _clientId;
  String get clientEmail => _clientEmail;

  Future load() async {
    if (_storage != null) {
      return;
    }
    _storage = FlutterSecureStorage();
    Map<String, String> vals = await _storage.readAll();
    _authToken = vals['authToken'];
    _clientId = vals['clientId'];
    _clientEmail = vals['cleintEmail'];
    _validate();
  }

  _save() async {
    _validate();
    _storage.deleteAll();
    if (_authToken != null && _authToken.isNotEmpty) {
      _storage.write(key: 'authToken', value: _authToken);
    }
    if (_clientId != null && _clientId.isNotEmpty) {
      _storage.write(key: 'clientId', value: _clientId);
    }
    if (_clientEmail != null && _clientEmail.isNotEmpty) {
      _storage.write(key: 'cleintEmail', value: _clientEmail);
    }
  }

  _validate() {
    if (_clientId == null ||
        _clientId.isEmpty ||
        _clientEmail == null ||
        _clientEmail.isEmpty) {
      _authToken = '';
      _clientId = '';
      _clientEmail = '';
    }
  }

  Future<String> register(String email, String password) async {
    _clientId = "1";
    _clientEmail = email;
    _save();
    return '';
  }

  Future<String> login(String email, String password) async {
    _clientId = "1";
    _clientEmail = email;
    _authToken = "2";
    _save();
    return '';
  }
}
