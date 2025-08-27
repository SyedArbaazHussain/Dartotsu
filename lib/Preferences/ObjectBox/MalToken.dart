import 'package:objectbox/objectbox.dart';

@Entity()
class ResponseToken {
  @Id()
  int id = 0;

  @Unique()
  late String key;

  String tokenType;
  int expiresIn;
  String accessToken;
  String refreshToken;

  ResponseToken({
    required this.tokenType,
    required this.expiresIn,
    required this.accessToken,
    required this.refreshToken,
  });

  factory ResponseToken.fromJson(Map<String, dynamic> json) {
    return ResponseToken(
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'expires_in': expiresIn,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
