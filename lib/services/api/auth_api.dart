// lib/services/api/auth_api.dart
import 'package:dio/dio.dart';
import '../../models/auth/user.dart';
import '../../models/auth/auth_result.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  // Sign in with username/email and password
  Future<AuthResult> signIn(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'identifier': username,
          'password': password,
        },
      );

      return AuthResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Register new user
  Future<AuthResult> signUp({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
          if (gender != null) 'gender': gender,
        },
      );

      return AuthResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Refresh access token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      return response.data['accessToken'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    try {
      await _dio.post(
        '/api/auth/update',
        data: {
          'email': email,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout and invalidate tokens
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        '/api/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      // We still want to clear local tokens even if server request fails
      print('Logout error: ${e.message}');
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/auth/me');
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return UnauthorizedException(
            e.response?.data?['error'] ?? 'Invalid credentials');
      }

      if (e.response!.statusCode == 409) {
        return ConflictException(
            e.response?.data?['error'] ?? 'Account already exists');
      }

      if (e.response!.statusCode == 400) {
        final errors = e.response?.data?['errors'];
        if (errors is List && errors.isNotEmpty) {
          return ValidationException(
              errors.map((e) => '${e['param']}: ${e['msg']}').join(', '));
        }
        return ValidationException(
            e.response?.data?['error'] ?? 'Invalid data provided');
      }

      return ServerException(e.response?.data?['error'] ?? 'Server error');
    }

    return NetworkException('Network error: ${e.message}');
  }
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}
