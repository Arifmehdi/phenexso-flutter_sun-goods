// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/models/user.dart' as hubli_user; // Alias for general User model
import 'package:sungoods/models/chat/user.dart' as chat_user; // Alias for chat User model

class UserService {
  final String? _authToken; // Make authToken nullable

  UserService(this._authToken); // Updated constructor

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<List<chat_user.User>> fetchAllUsers() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/chat/users/search',
      ), // Assuming an /users endpoint
      headers: _getHeaders(),
    );

    debugPrint('API Response Status Code: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Assuming the API returns a list of users directly under a 'data' key or similar
      if (data['users'] != null && data['users'] is List) {
        return (data['users'] as List)
            .map((json) => chat_user.User.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid user data format');
      }
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<hubli_user.User> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/user/profile'), // Assumed API endpoint
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return hubli_user.User.fromJson(data);
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }

  Future<hubli_user.User> updateUserProfile(hubli_user.User user) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/api/user/profile'), // Corrected API endpoint and method
      headers: _getHeaders(),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return hubli_user.User.fromJson(data);
    } else {
      throw Exception('Failed to update user profile: ${response.statusCode}');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword, String confirmPassword) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/user/password');
    final body = json.encode({
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    });

    debugPrint('Change Password API URL: $uri');
    debugPrint('Change Password Request Body: $body');

    final response = await http.patch(
      uri,
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      // Password changed successfully, no content expected
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
          errorData['message'] ?? 'Failed to change password: ${response.statusCode}');
    }
  }
}
