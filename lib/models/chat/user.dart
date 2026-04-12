// lib/models/chat/user.dart
// Helper function to safely parse int, returns 0 if null or invalid
int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty) return 0;
    try {
      return int.parse(value);
    } catch (_) {
      return 0;
    }
  }
  return 0;
}

class User {
  final int id;
  final String name;
  final String? email;
  final String? userType;
  final String? profilePhoto;

  User({
    required this.id,
    required this.name,
    this.email,
    this.userType,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _safeParseInt(json['id']),
      name: json['name'],
      email: json['email'],
      userType: json['user_type'],
      profilePhoto: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_type': userType,
      'profile_photo': profilePhoto,
    };
  }
}
