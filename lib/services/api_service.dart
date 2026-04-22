// lib/services/api_service.dart
/*
 -----------------------------------------------------------------------------
 Simply Systems
 A mobile app (iOS & Android) for plural systems to manage system members,
 track fronting history, communicate internally via real-time chat, etc.
-----------------------------------------------------------------------------
 Copyright (C) 2026 Vayrian

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published
 by the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see https://www.gnu.org/licenses/.

*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;  

class ApiService {
  // Dynamic base URL: different for web vs mobile
  static String get baseUrl {
    if (kIsWeb) {
      // Web: use relative URL locally, or Render URL in production
      if (kDebugMode) {
        return 'http://localhost:5000'; // local backend
      } else {
        return 'https://simply-systems-api.onrender.com'; // deployed backend
      }
    } else {
      // Mobile (Android emulator / iOS simulator / physical device)
      return 'https://simply-systems-api.onrender.com'; // deployed backend
      // For local dev on emulator: return 'http://10.0.2.2:5000';
      // For physical device on same Wi-Fi: return 'http://192.168.x.x:5000';
    }
  }

  Future<Map<String, String>> _getAuthHeaders({String? providedToken}) async {
    String? token = providedToken;
    if (token == null) {
      final secureStorage = const FlutterSecureStorage();
      token = await secureStorage.read(key: 'jwt_token');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Register
  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return body;
    } else {
      throw Exception(body['error'] ?? 'Registration failed (${response.statusCode})');
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['error'] ?? 'Login failed (${response.statusCode})');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: await _getAuthHeaders(providedToken: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile (${response.statusCode})');
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateUserProfile(
    String token, {
    bool? isSystemOwner,
    String? displayName,
  }) async {
    final data = <String, dynamic>{};
    if (isSystemOwner != null) data['is_system_owner'] = isSystemOwner;
    if (displayName != null) data['display_name'] = displayName.trim();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: await _getAuthHeaders(providedToken: token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile (${response.statusCode})');
    }
  }

  // Set current fronter
  Future<Map<String, dynamic>> setCurrentFrenter(
    String token, {
    String? memberId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/user/current_fronter'),
      headers: await _getAuthHeaders(providedToken: token),
      body: jsonEncode({'member_id': memberId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to set current fronter (${response.statusCode})');
    }
  }

  // Get all members
  Future<List<dynamic>> getMembers({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/members'),
      headers: await _getAuthHeaders(providedToken: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch members (${response.statusCode})');
    }
  }

  // Create member
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> data, {required String token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/members'),
      headers: await _getAuthHeaders(providedToken: token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create member (${response.statusCode})');
    }
  }

  // Update member
  Future<void> updateMember(int id, Map<String, dynamic> data, {required String token}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/members/$id'),
      headers: await _getAuthHeaders(providedToken: token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update member (${response.statusCode})');
    }
  }

  // Delete member
  Future<void> deleteMember(int id, {required String token}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/members/$id'),
      headers: await _getAuthHeaders(providedToken: token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete member (${response.statusCode})');
    }
  }

  // Get front history
  Future<List<dynamic>> getFrontHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/front-history'),
      headers: await _getAuthHeaders(providedToken: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch front history (${response.statusCode})');
    }
  }

  // Get messages
  Future<List<dynamic>> getMessages(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages'),
      headers: await _getAuthHeaders(providedToken: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch messages (${response.statusCode})');
    }
  }
}
