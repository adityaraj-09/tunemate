// lib/services/user_preference_service.dart
import 'package:app/models/music/user_pref.dart';
import 'package:dio/dio.dart';


class UserPreferenceService {
  final Dio _dio;

  UserPreferenceService(this._dio);

  /// Get current user's preferences
  Future<UserPreference?> getUserPreferences() async {
    try {
      final response = await _dio.get('/api/preferences');

      if (response.data["preferences"] != null) {
        return UserPreference.fromJson(response.data["preferences"]);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user preferences (create or update)
  Future<UserPreference> updatePreferences({
    GenderPreference? preferredGender,
    String? customGenderPreference,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVisible,
  }) async {
    try {
      // Build request data
      final data = <String, dynamic>{};
      
      // Handle gender preference
      if (preferredGender != null) {
        String genderValue;
        switch (preferredGender) {
          case GenderPreference.male:
            genderValue = 'male';
            break;
          case GenderPreference.female:
            genderValue = 'female';
            break;
          case GenderPreference.any:
            genderValue = 'any';
            break;
          case GenderPreference.nonBinary:
            genderValue = 'non-binary';
            break;
          case GenderPreference.custom:
            genderValue = customGenderPreference ?? 'custom';
            break;
        }
        data['preferredGender'] = genderValue;
      }
      
      // Add other fields if provided
      if (minAge != null) data['minAge'] = minAge;
      if (maxAge != null) data['maxAge'] = maxAge;
      if (maxDistance != null) data['maxDistance'] = maxDistance;
      if (isVisible != null) data['isVisible'] = isVisible;
      
      final response = await _dio.post(
        '/api/preferences',
        data: data,
      );

      return UserPreference.fromJson(response.data["preferences"]);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update specific fields of user preferences
  Future<UserPreference> updateSpecificPreferences({
    GenderPreference? preferredGender,
    String? customGenderPreference,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVisible,
  }) async {
    try {
      // Build request data
      final data = <String, dynamic>{};
      
      // Handle gender preference
      if (preferredGender != null) {
        String genderValue;
        switch (preferredGender) {
          case GenderPreference.male:
            genderValue = 'male';
            break;
          case GenderPreference.female:
            genderValue = 'female';
            break;
          case GenderPreference.any:
            genderValue = 'any';
            break;
          case GenderPreference.nonBinary:
            genderValue = 'non-binary';
            break;
          case GenderPreference.custom:
            genderValue = customGenderPreference ?? 'custom';
            break;
        }
        data['preferredGender'] = genderValue;
      }
      
      // Add other fields if provided
      if (minAge != null) data['minAge'] = minAge;
      if (maxAge != null) data['maxAge'] = maxAge;
      if (maxDistance != null) data['maxDistance'] = maxDistance;
      if (isVisible != null) data['isVisible'] = isVisible;
      
      if (data.isEmpty) {
        throw Exception('No update fields provided');
      }

      final response = await _dio.put(
        '/api/preferences',
        data: data,
      );

      return UserPreference.fromJson(response.data["preferences"]);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset preferences to defaults
  Future<UserPreference> resetPreferences() async {
    try {
      final response = await _dio.delete('/api/preferences');
      return UserPreference.fromJson(response.data["preferences"]);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get preference recommendations based on music taste
  Future<Map<String, dynamic>> getPreferenceRecommendations() async {
    try {
      final response = await _dio.get('/api/preferences/recommendations');
      
      return {
        'recommendations': response.data["recommendations"],
        'topGenres': response.data["topGenres"],
        'message': response.data["message"],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get compatibility with another user
  Future<Map<String, dynamic>> getCompatibilityWithUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }
      
      final response = await _dio.get('/api/preferences/compatibility/$userId');
      
      return {
        'compatibility': response.data["compatibility"],
        'myPreferences': response.data["myPreferences"] != null 
            ? UserPreference.fromJson(response.data["myPreferences"])
            : null,
        'theirPreferences': response.data["theirPreferences"] != null 
            ? {
                'preferredGender': response.data["theirPreferences"]["preferredGender"],
                'minAge': response.data["theirPreferences"]["minAge"],
                'maxAge': response.data["theirPreferences"]["maxAge"],
              }
            : null,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      String message = 'Unknown error occurred';
      if (data != null && data is Map && data.containsKey('error')) {
        message = data['error'];
      }
      
      switch (statusCode) {
        case 400:
          return Exception('Invalid request: $message');
        case 401:
          return Exception('Unauthorized: $message');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not found: $message');
        case 500:
          return Exception('Server error: $message');
        default:
          return Exception('Error ${statusCode}: $message');
      }
    }
    
    return Exception('Network error: ${e.message}');
  }
}