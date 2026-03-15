// lib/providers/auth_provider.dart


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _token;
  bool _isLoading = true;
  String? _errorMessage;

  int? _userId;
  String? _email;
  bool _isSystemOwner = false;
  String? _displayName;

  String? get token => _token;
  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  int? get userId => _userId;
  String? get email => _email;
  bool get isSystemOwner => _isSystemOwner;
  String? get displayName => _displayName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _isLoading = true;
    notifyListeners();

    final storedToken = await _storage.read(key: 'jwt_token');
    if (storedToken != null && !JwtDecoder.isExpired(storedToken)) {
      _token = storedToken;
      await _fetchUserProfile();
    } else {
      _token = null;
      if (storedToken != null) await _storage.delete(key: 'jwt_token');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setToken(String newToken, {Map<String, dynamic>? userData}) async {
    _token = newToken;
    await _storage.write(key: 'jwt_token', value: newToken);

    if (userData != null) {
      _userId = userData['id'];
      _email = userData['email'];
      _isSystemOwner = userData['is_system_owner'] ?? false;
      _displayName = userData['display_name'];
    }

    await _fetchUserProfile();
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    if (_token == null) return;

    try {
      final api = ApiService();
      final profile = await api.getUserProfile(_token!);
      _userId = profile['id'];
      _email = profile['email'];
      _isSystemOwner = profile['is_system_owner'] ?? false;
      _displayName = profile['display_name'];
      notifyListeners();
    } catch (e) {
      debugPrint('Profile fetch failed: $e');
    }
  }

  Future<void> updateProfile({
    bool? isSystemOwner,
    String? displayName,
  }) async {
    try {
      final api = ApiService();
      final updated = await api.updateUserProfile(
        _token!,
        isSystemOwner: isSystemOwner,
        displayName: displayName,  
      );
      _isSystemOwner = updated['is_system_owner'] ?? _isSystemOwner;
      _displayName = updated['display_name'] ?? _displayName;
      notifyListeners();
    } catch (e) {
      debugPrint('Profile update failed: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    _isSystemOwner = false;
    _displayName = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}