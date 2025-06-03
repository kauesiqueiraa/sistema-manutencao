class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String scope;
  final String tokenType;
  final int expiresIn;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.scope,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      scope: json['scope'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'scope': scope,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
} 