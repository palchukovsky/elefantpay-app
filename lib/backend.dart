abstract class Request {
  Map<String, dynamic> toJson();
}

class Error {
  final String message;

  Error(this.message);

  factory Error.fromJson(final Map<String, dynamic> json) {
    return Error(json['message']);
  }
}

class ClientEmail extends Request {
  final String email;

  ClientEmail(this.email);

  @override
  Map<String, dynamic> toJson() => {'email': email};
}

class ClientCredentials extends Request {
  final String email;
  final String password;

  ClientCredentials(this.email, this.password);

  @override
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class ClientRegistration extends Request {
  final String name;
  final String email;
  final String password;

  ClientRegistration(this.name, this.email, this.password);

  @override
  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'password': password};
}

class ClientInfo {
  final String name;
  final String email;

  ClientInfo(this.name, this.email);

  factory ClientInfo.fromJson(final Map<String, dynamic> json) {
    return ClientInfo(json['name'], json['email']);
  }
}

class CredentialsConfirmationRequest {
  final String confirmation;

  CredentialsConfirmationRequest(this.confirmation);

  factory CredentialsConfirmationRequest.fromJson(
      final Map<String, dynamic> json) {
    return CredentialsConfirmationRequest(json['confirmation']);
  }
}

class CredentialsConfirmation extends Request {
  final String id;
  final String token;

  CredentialsConfirmation(this.id, this.token);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'token': token};
}

class AccountInfo {
  final String currency;

  AccountInfo(this.currency);

  factory AccountInfo.fromJson(final Map<String, dynamic> json) {
    return AccountInfo(json['currency']);
  }
}

class AccountInfoDict {
  final Map<String, AccountInfo> accounts;

  AccountInfoDict(this.accounts);

  factory AccountInfoDict.fromJson(final Map<String, dynamic> json) {
    final result = Map<String, AccountInfo>();
    json.forEach((k, v) {
      result[k] = AccountInfo.fromJson(v);
    });
    return AccountInfoDict(result);
  }
}

class AccountAction {
  final DateTime time;
  final double value;
  final String subject;
  final String state;
  final String notes;

  AccountAction(this.time, this.value, this.subject, this.state, this.notes);

  factory AccountAction.fromJson(final Map<String, dynamic> json) {
    return AccountAction(_parseDateTime(json['time']), json['value'],
        json['subject'], json['state'], json['notes']);
  }
}

class AccountDetails {
  final String currency;
  final double balance;
  final int revision;
  final List<AccountAction> history;

  AccountDetails(this.currency, this.balance, this.revision, this.history);

  factory AccountDetails.fromJson(final Map<String, dynamic> json) {
    final List historyNode = json['history'];
    final history = List<AccountAction>();
    historyNode.forEach((i) => history.add(AccountAction.fromJson(i)));
    return AccountDetails(json['currency'], json['balance'].toDouble(),
        json['revision'], history);
  }
}

DateTime _parseDateTime(final dynamic source) {
  final String str = source;
  return DateTime.parse(str);
}
