import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final session = _Session();

class _Session {
  FlutterSecureStorage _storage;

  String _authToken;
  String _clientId;
  String _clientEmail;

  bool get isAuthed => _authToken != null;
  String authToken() => _authToken;

  bool get isRegistered => _clientId != null;
  String get clientId => _clientId;
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
    _authToken = vals['authToken'];
    _clientId = vals['clientId'];
    _clientEmail = vals['clientEmail'];
    _validate();
  }

  _save() async {
    _validate();
    _storage.deleteAll();
    _writeKey('authToken', _authToken);
    _writeKey('clientId', _clientId);
    _writeKey('clientEmail', _clientEmail);
    _read();
  }

  _writeKey(String key, String value) async {
    if (value == null) {
      return;
    }
    _storage.write(key: key, value: value);
  }

  _validate() {
    if (_clientId == null || _clientEmail == null) {
      _authToken = null;
      _clientId = null;
      _clientEmail = null;
    }
  }

  Future<String> register(String email, String password) async {
    _clientId = "1";
    _clientEmail = email;
    _save();
    return null;
  }

  Future<String> login(String email, String password) async {
    _clientId = "1";
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
}
