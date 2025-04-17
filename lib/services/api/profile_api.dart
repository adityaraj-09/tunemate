// lib/services/api/profile_api.dart
import 'package:app/models/music/models.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../models/auth/user.dart';

class ProfileApiService {
  final Dio _dio;

  ProfileApiService(this._dio);

  // Get user profile details
  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    DateTime? birthDate,
    String? gender,
    Map<String, dynamic>? preferences,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (birthDate != null) data['birthDate'] = birthDate.toIso8601String();
      if (gender != null) data['gender'] = gender;
      if (preferences != null) data['preferences'] = preferences;
      if (photoUrl != null) data['profilePicture'] = photoUrl;

      final response = await _dio.patch('/api/profile', data: data);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'profile_photo.jpg',
        ),
      });

      final response = await _dio.post(
        '/api/profile/photo',
        data: formData,
      );

      return response.data['photoUrl'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's music taste
  Future<MusicTaste> getMusicTaste() async {
    try {
      final response = await _dio.get('/api/profile/music-taste');
      return MusicTaste.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get favorite songs
  Future<List<dynamic>> getFavoriteSongs(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/api/users/music/favorites',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

    
        return response.data['favorites'];
      

    
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get listening history
  Future<dynamic> getListeningHistory(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/api/users/music/history',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data['success'] && response.data['history'] != null) {
        return response.data;
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user matches
  Future<List<Match>> getMatches({int limit = 20, int minScore = 0}) async {
    try {
      final response = await _dio.get(
        '/api/matches/get',
        queryParameters: {
          'limit': limit,
          'minScore': minScore,
        },
      );

      if ( response.data['matches'] != null) {
        return (response.data['matches'] as List)
            .map((match) => Match.fromJson(match))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get match details
  Future<Match> getMatchDetails(String matchId) async {
    try {
      final response = await _dio.get('/api/matches/$matchId');
      return Match.fromJson(response.data['match']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update music preferences
  Future<void> updateMusicPreferences(Map<String, dynamic> preferences) async {
    try {
      await _dio.patch(
        '/api/profile/music-preferences',
        data: preferences,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get compatibility score with another user
  Future<double> getCompatibilityScore(String userId) async {
    try {
      final response = await _dio.get('/api/profile/compatibility/$userId');
      return response.data['score'] as double;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return UnauthorizedException(
            e.response?.data?['error'] ?? 'Unauthorized access');
      }

      if (e.response!.statusCode == 404) {
        return NotFoundException(
            e.response?.data?['error'] ?? 'Resource not found');
      }

      if (e.response!.statusCode == 400) {
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
