class User {
  final String id;
  final String email;
  final String username;
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}