class User {
  final int? id;
  final String username;
  final String password;
  final String nama;
  final String role;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nama': nama,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      nama: map['nama'],
      role: map['role'],
    );
  }
}
