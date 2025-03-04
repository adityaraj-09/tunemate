// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api/auth_api.dart';
import '../services/storage/secure_storage.dart';
import '../models/auth/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  registering,
  error
}

class AuthProvider with ChangeNotifier {
  final AuthApiService _authApi;
  final SecureStorageService _storage;
  
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;
  
  AuthProvider(this._authApi, this._storage) {
    // Check if user is already authenticated
    _checkAuthStatus();
  }
  
  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;
  bool get isRegistering => _status == AuthStatus.registering;
  bool get hasError => _status == AuthStatus.error;
  
  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        _setUnauthenticated();
        return;
      }
      
      // Try to get current user data
      _currentUser = await _storage.getUser();
      
      if (_currentUser != null) {
        _setAuthenticated();
        
        // Fetch fresh user data in background
        _refreshUserData();
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setUnauthenticated();
    }
  }
  
  // Refresh user data from the API
  Future<void> _refreshUserData() async {
    try {
      final freshUser = await _authApi.getCurrentUser();
      _currentUser = freshUser;
      await _storage.saveUser(freshUser);
      notifyListeners();
    } catch (e) {
      // Just log the error but don't change authentication state
      print('Error refreshing user data: $e');
    }
  }
  
  // Sign in with username/email and password
  Future<bool> signIn(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _authApi.signIn(username, password);
      
      // Save to secure storage
      await _storage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken
      );
      await _storage.saveUser(result.user);
      
      _currentUser = result.user;
      _setAuthenticated();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setError();
      return false;
    }
  }
  
  // Register new user
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
  }) async {
    _status = AuthStatus.registering;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _authApi.signUp(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        gender: gender,
      );
      
      // Save to secure storage
      await _storage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken
      );
      await _storage.saveUser(result.user);
      
      _currentUser = result.user;
      _setAuthenticated();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setError();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _authApi.logout(refreshToken);
      }
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      await _storage.clearAll();
      _currentUser = null;
      _setUnauthenticated();
    }
  }
  
  // Set state to authenticated
  void _setAuthenticated() {
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }
  
  // Set state to unauthenticated
  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
  
  // Set state to error
  void _setError() {
    _status = AuthStatus.error;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }
   void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}