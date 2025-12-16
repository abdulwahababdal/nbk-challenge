class User {
  final String token;
  final String username;
  final String fullName;
  final DateTime expiresAt;

  User({
    required this.token,
    required this.username,
    required this.fullName,
    required this.expiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'fullName': fullName,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
