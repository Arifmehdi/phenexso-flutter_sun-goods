// lib/services/admin_user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// For debugPrint
import 'package:sungoods/utils/api_constants.dart';
// General app User model

class AdminUserService {
  final String _authToken;

  AdminUserService(this._authToken);

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  Future<Map<String, dynamic>> fetchAllUsers({int page = 1}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/users?page=$page&per_page=100'),
      headers: _getHeaders(),
    );

    // debugPrint('AdminUserService - API Response Status Code: ${response.statusCode}');
    // debugPrint('AdminUserService - API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // This 'data' now contains the full Laravel pagination structure, including the 'data' key for users.
      // The provider will extract the users and pagination metadata.
      return data;
    } else {
      throw Exception('Failed to load general users: ${response.statusCode}');
    }
  }
}
