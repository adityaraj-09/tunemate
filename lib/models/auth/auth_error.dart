class AuthError {
  final String message;
  final String? field;
  final String? code;

  AuthError({
    required this.message,
    this.field,
    this.code,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] ?? 'An unknown error occurred',
      field: json['field'],
      code: json['code'],
    );
  }

  @override
  String toString() => message;
}