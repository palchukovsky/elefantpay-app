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

class ClientCredentials extends Request {
  final String email;
  final String password;

  ClientCredentials(this.email, this.password);

  @override
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class CredentialsConfirmationRequest {
  final String confirmation;

  CredentialsConfirmationRequest(this.confirmation);

  factory CredentialsConfirmationRequest.fromJson(Map<String, dynamic> json) {
    return CredentialsConfirmationRequest(json['confirmation']);
  }
}
