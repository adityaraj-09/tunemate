// lib/models/auth/user.dart
class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final String? bio;
  final DateTime? birthDate;
  final int? age;
  final String? gender;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.bio,
    this.birthDate,
    this.age,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePicture'],
      bio: json['bio'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePictureUrl,
      'bio': bio,
      'birthDate': birthDate?.toIso8601String(),
      'age': age,
      'gender': gender,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    String? bio,
    DateTime? birthDate,
    int? age,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
}

