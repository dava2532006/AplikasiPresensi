class User {
  final String uid;
  final String name;
  final String email;
  final String position;
  final String role;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.position,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      position: data['position'] ?? '',
      role: data['role'] ?? '',
    );
  }
}