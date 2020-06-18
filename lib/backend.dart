abstract class Request {
  Map<String, dynamic> toJson();
}

class Error {
  final String message;

  Error(this.message);

  factory Error.fromJson(Map<String, dynamic> json) {
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

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(json['name'], json['email']);
  }
}

class CredentialsConfirmationRequest {
  final String confirmation;

  CredentialsConfirmationRequest(this.confirmation);

  factory CredentialsConfirmationRequest.fromJson(Map<String, dynamic> json) {
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
