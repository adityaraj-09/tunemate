// lib/services/api/music_api.dart
import 'package:app/models/music/music_prefernces.dart';
import 'package:dio/dio.dart';

class PreferenceApiService {
  final Dio _dio;

  PreferenceApiService(this._dio);

  // Fetch available languages for music preference
  Future<List<MusicPreference>> getAvailableLanguages() async {
    try {
      final response = await _dio.get('/api/music/languages');
      return (response.data['languages'] as List)
          .map((lang) => MusicPreference.fromJson(lang))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Fetch available genres for music preference
  Future<List<MusicPreference>> getAvailableGenres() async {
    try {
      final response = await _dio.get('/api/music/genres');
      return (response.data['genres'] as List)
          .map((genre) => MusicPreference.fromJson(genre))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Fetch available artists for music preference
  Future<List<MusicPreference>> getAvailableArtists() async {
    try {
      final response = await _dio.get('/api/music/artists');
      return (response.data['artists'] as List)
          .map((artist) => MusicPreference.fromJson(artist))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search artists by name
  Future<List<MusicPreference>> searchArtists(String query) async {
    try {
      final response = await _dio
          .get('/api/music/artists/search', queryParameters: {'q': query});
      return (response.data['artists'] as List)
          .map((artist) => MusicPreference.fromJson(artist))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update user music preferences
  Future<void> updateMusicPreferences(MusicPreferences preferences) async {
    try {
      await _dio.post(
        '/api/user/music-preferences',
        data: preferences.toJson(),
      );
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

      if (e.response!.statusCode == 400) {
        return ValidationException(
            e.response?.data?['error'] ?? 'Invalid data provided');
      }

      return ServerException(e.response?.data?['error'] ?? 'Server error');
    }

    return NetworkException('Network error: ${e.message}');
  }
}

// Using the same exception classes as AuthApiService
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
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
