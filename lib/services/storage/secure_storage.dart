// lib/services/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/auth/user.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  
  final FlutterSecureStorage _storage;
  
  SecureStorageService(this._storage);
  
  // Save access token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Get access token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Save both tokens
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await saveToken(accessToken);
    await saveRefreshToken(refreshToken);
  }
  
  // Clear both tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  // Save current user
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }
  
  // Get current user
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    
    try {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      return User.fromJson(userData);
    } catch (e) {
      print('Failed to parse user data: $e');
      return null;
    }
  }
  
  // Clear user data
  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
  
  // Clear all stored data
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}