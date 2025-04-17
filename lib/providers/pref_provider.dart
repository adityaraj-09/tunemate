// lib/providers/user_preference_provider.dart
import 'package:app/models/music/user_pref.dart';
import 'package:app/services/api/user_pref.dart';
import 'package:flutter/foundation.dart';


class UserPreferenceProvider with ChangeNotifier {
  final UserPreferenceService _preferenceService;
  
  UserPreference? _preferences;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _recommendations;

  // Getters
  UserPreference? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  Map<String, dynamic>? get recommendations => _recommendations;

  // Constructor
  UserPreferenceProvider({required UserPreferenceService preferenceService})
      : _preferenceService = preferenceService {
    // Initialize by fetching preferences
    loadPreferences();
  }

  // Load user preferences
  Future<void> loadPreferences() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final preferences = await _preferenceService.getUserPreferences();
      _preferences = preferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user preferences
  Future<void> updatePreferences({
    GenderPreference? preferredGender,
    String? customGenderPreference,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVisible,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPreferences = await _preferenceService.updatePreferences(
        preferredGender: preferredGender,
        customGenderPreference: customGenderPreference,
        minAge: minAge,
        maxAge: maxAge,
        maxDistance: maxDistance,
        isVisible: isVisible,
      );

      _preferences = updatedPreferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update specific preference fields
  Future<void> updateSpecificPreferences({
    GenderPreference? preferredGender,
    String? customGenderPreference,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVisible,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPreferences = await _preferenceService.updateSpecificPreferences(
        preferredGender: preferredGender,
        customGenderPreference: customGenderPreference,
        minAge: minAge,
        maxAge: maxAge,
        maxDistance: maxDistance,
        isVisible: isVisible,
      );

      _preferences = updatedPreferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset preferences to defaults
  Future<void> resetPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final defaultPreferences = await _preferenceService.resetPreferences();
      _preferences = defaultPreferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get preference recommendations based on music taste
  Future<void> loadRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _preferenceService.getPreferenceRecommendations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load recommendations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply recommendations
  Future<void> applyRecommendations() async {
    if (_recommendations == null || 
        _recommendations!['recommendations'] == null) {
      _error = 'No recommendations available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recommendedPrefs = _recommendations!['recommendations'];
      
      // Keep gender preference as it's highly personal
      final updatedPreferences = await _preferenceService.updateSpecificPreferences(
        minAge: recommendedPrefs['minAge'],
        maxAge: recommendedPrefs['maxAge'],
        maxDistance: recommendedPrefs['maxDistance'],
      );

      _preferences = updatedPreferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to apply recommendations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get compatibility with another user
  Future<Map<String, dynamic>> getCompatibilityWithUser(String userId) async {
    try {
      return await _preferenceService.getCompatibilityWithUser(userId);
    } catch (e) {
      _error = 'Failed to calculate compatibility: $e';
      notifyListeners();
      throw e;
    }
  }

  // Helper method to get formatted age range
  String getAgeRangeText() {
    if (_preferences == null) return 'Not set';
    
    return _preferences!.getAgeRangeDisplay();
  }

  // Helper method to get formatted distance preference
  String getDistanceText() {
    if (_preferences == null) return 'Not set';
    
    return _preferences!.getDistanceDisplay();
  }

  // Helper method to get formatted gender preference
  String getGenderPreferenceText() {
    if (_preferences == null) return 'Not set';
    
    return _preferences!.getGenderPreferenceDisplay();
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}