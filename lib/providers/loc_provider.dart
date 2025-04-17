// lib/providers/location_provider.dart
import 'package:app/models/music/location.dart';
import 'package:app/services/api/location_api.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class LocationProvider with ChangeNotifier {
  final LocationApiService _locationService;
  
  UserLocation? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;

  // Getters
  UserLocation? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get locationPermissionGranted => _locationPermissionGranted;

  // Constructor
  LocationProvider({required LocationApiService locationService})
      : _locationService = locationService {
    // Initialize by checking location permission and fetching location
    _init();
  }

  // Initialize the provider
  Future<void> _init() async {
    try {
      // Check if location permissions are already granted
      final permission = await Geolocator.checkPermission();
      _locationPermissionGranted = permission == LocationPermission.always ||
                                  permission == LocationPermission.whileInUse;
      
      if (_locationPermissionGranted) {
        // Try to get location from the server
        await getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error initializing location provider: $e');
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable them in settings.';
        notifyListeners();
        return false;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied.';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied. Please enable them in app settings.';
        notifyListeners();
        return false;
      }

      _locationPermissionGranted = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error requesting location permission: $e';
      notifyListeners();
      return false;
    }
  }

  // Get current location from server
  Future<UserLocation?> getCurrentLocation() async {
    if (_isLoading) return _currentLocation;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.getUserLocation();
      _currentLocation = location;
      _isLoading = false;
      notifyListeners();
      return location;
    } catch (e) {
      _error = 'Failed to get current location: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update location with given coordinates and address
  Future<UserLocation?> updateLocation({
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.updateLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
        state: state,
        country: country,
      );

      _currentLocation = location;
      _isLoading = false;
      notifyListeners();
      return location;
    } catch (e) {
      _error = 'Failed to update location: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update location with current device position
  Future<UserLocation?> updateWithCurrentDevicePosition() async {
    if (!_locationPermissionGranted) {
      final granted = await requestLocationPermission();
      if (!granted) return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current device position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address details from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? city, state, country;
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        city = place.locality;
        state = place.administrativeArea;
        country = place.country;
      }

      // Update location on server
      final location = await _locationService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        state: state,
        country: country,
      );

      _currentLocation = location;
      _isLoading = false;
      notifyListeners();
      return location;
    } catch (e) {
      _error = 'Failed to update location: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete location
  Future<bool> deleteLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _locationService.deleteLocation();
      if (success) {
        _currentLocation = null;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to delete location: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get nearby users
  Future<List<NearbyUser>> getNearbyUsers({double radius = 50}) async {
    try {
      return await _locationService.getNearbyUsers(radius: radius);
    } catch (e) {
      _error = 'Failed to get nearby users: $e';
      notifyListeners();
      return [];
    }
  }

  // Calculate distance to another user
  Future<double?> getDistanceToUser(String userId) async {
    try {
      final result = await _locationService.getDistanceToUser(userId);
      return result['distance'] as double?;
    } catch (e) {
      _error = 'Failed to calculate distance: $e';
      notifyListeners();
      return null;
    }
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}