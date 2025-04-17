// lib/services/location_api_service.dart
import 'package:app/models/music/location.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class LocationApiService {
  final Dio _dio;

  LocationApiService(this._dio);

  /// Get current user's location
  Future<UserLocation?> getUserLocation() async {
    try {
      final response = await _dio.get('/api/location');

      if (response.data["location"] != null) {
        return UserLocation.fromJson(response.data["location"]);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update or create user location
  Future<UserLocation> updateLocation({
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? country,
  }) async {
    try {
      final response = await _dio.post(
        '/api/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (country != null) 'country': country,
        },
      );

      return UserLocation.fromJson(response.data["location"]);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update specific fields of user location
  Future<UserLocation> updateLocationFields({
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (country != null) data['country'] = country;

      if (data.isEmpty) {
        throw Exception('No update fields provided');
      }

      final response = await _dio.put(
        '/api/location',
        data: data,
      );

      return UserLocation.fromJson(response.data["location"]);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete user location
  Future<bool> deleteLocation() async {
    try {
      final response = await _dio.delete('/api/location');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get nearby users
  Future<List<NearbyUser>> getNearbyUsers({
    double? radius = 50,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'radius': radius,
      };

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }

      final response = await _dio.get(
        '/api/location/nearby',
        queryParameters: queryParams,
      );

      if (response.data["users"] != null) {
        return (response.data["users"] as List)
            .map((userData) => NearbyUser.fromJson(userData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Calculate distance to another user
  Future<Map<String, dynamic>> getDistanceToUser(String userId) async {
    try {
      final response = await _dio.get('/api/location/distance/$userId');

      return {
        'distance': response.data['distance'],
        'units': response.data['units'],
        'yourLocation': UserLocationBasic.fromJson(response.data['yourLocation']),
        'theirLocation': UserLocationBasic.fromJson(response.data['theirLocation']),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update location with current device position
  Future<UserLocation> updateWithCurrentPosition() async {
    try {
      // Get current position
      final position = await _getCurrentPosition();

      // Update location
      return await updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get current position from device
  Future<Position> _getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions');
    }

    // Get position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Reverse geocode a location to get address details
  // Future<Map<String, String?>> reverseGeocode(double latitude, double longitude) async {
  //   try {
  //     // Use native geocoding
  //     final placemarks = await Geolocator.g(
  //       Position(
  //         latitude: latitude,
  //         longitude: longitude,
  //         timestamp: DateTime.now(),
  //         accuracy: 0,
  //         altitude: 0,
  //         heading: 0,
  //         speed: 0,
  //         speedAccuracy: 0,
  //         altitudeAccuracy: 0,
  //         headingAccuracy: 0,
  //       ),
  //     );

  //     if (placemarks.isNotEmpty) {
  //       final placemark = placemarks.first;
  //       return {
  //         'city': placemark.locality,
  //         'state': placemark.administrativeArea,
  //         'country': placemark.country,
  //       };
  //     }

  //     return {
  //       'city': null,
  //       'state': null,
  //       'country': null,
  //     };
  //   } catch (e) {
  //     // Silently fail geocoding, just return null values
  //     return {
  //       'city': null,
  //       'state': null,
  //       'country': null,
  //     };
  //   }
  // }

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
          return Exception('Bad request: $message');
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