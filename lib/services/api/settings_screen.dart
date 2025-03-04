// lib/services/api/settings_api.dart
import 'package:dio/dio.dart';

class SettingsApiService {
  final Dio _dio;

  SettingsApiService(this._dio);

  // Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _dio.get('/api/settings');
      
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['settings']);
      }
      
      throw ServerException('Failed to load settings');
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Update a specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _dio.patch(
        '/api/settings',
        data: {
          key: value,
        },
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Update multiple settings at once
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.patch(
        '/api/settings',
        data: settings,
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Get privacy settings
  Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      final response = await _dio.get('/api/settings/privacy');
      
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['privacySettings']);
      }
      
      throw ServerException('Failed to load privacy settings');
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Update a specific privacy setting
  Future<void> updatePrivacySetting(String key, dynamic value) async {
    try {
      await _dio.patch(
        '/api/settings/privacy',
        data: {
          key: value,
        },
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.patch(
        '/api/settings/notifications',
        data: settings,
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Update matching preferences
  Future<void> updateMatchingPreferences(Map<String, dynamic> preferences) async {
    try {
      await _dio.patch(
        '/api/settings/matching',
        data: preferences,
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/account');
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Request data export
  Future<String> requestDataExport() async {
    try {
      final response = await _dio.post('/api/settings/data-export');
      
      if (response.statusCode == 200) {
        return response.data['message'];
      }
      
      throw ServerException('Failed to request data export');
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Get blocked users
  Future<List<dynamic>> getBlockedUsers() async {
    try {
      final response = await _dio.get('/api/settings/blocked-users');
      
      if (response.statusCode == 200) {
        return response.data['blockedUsers'];
      }
      
      throw ServerException('Failed to load blocked users');
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Block a user
  Future<void> blockUser(String userId) async {
    try {
      await _dio.post(
        '/api/settings/blocked-users',
        data: {
          'userId': userId,
        },
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Unblock a user
  Future<void> unblockUser(String userId) async {
    try {
      await _dio.delete(
        '/api/settings/blocked-users/$userId',
      );
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioError e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return UnauthorizedException(
          e.response?.data?['error'] ?? 'Unauthorized access'
        );
      }
      
      if (e.response!.statusCode == 404) {
        return NotFoundException(
          e.response?.data?['error'] ?? 'Resource not found'
        );
      }
      
      if (e.response!.statusCode == 400) {
        return ValidationException(
          e.response?.data?['error'] ?? 'Invalid data provided'
        );
      }
      
      return ServerException(
        e.response?.data?['error'] ?? 'Server error'
      );
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

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
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