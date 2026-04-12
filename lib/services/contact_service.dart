import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ContactService {
  Future<bool> submitContactForm({
    required String? token,
    required String subject,
    required String message,
    String? userName,
    String? userMobile,
    String? userEmail,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/contact',
    ); // Use baseUrl from ApiConstants

    final Map<String, dynamic> requestBody = {
      'subject': subject,
      'message': message,
    };

    if (userName != null) {
      requestBody['name'] = userName;
    }
    if (userMobile != null) {
      requestBody['mobile'] = userMobile;
      requestBody['phone'] =
          userMobile; // Assuming mobile and phone are the same
    }
    if (userEmail != null) {
      requestBody['email'] = userEmail;
    }

    // debugPrint('Contact Form Request Body: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Explicitly request JSON response
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Contact Form API Response Status: ${response.statusCode}');
      debugPrint('Contact Form API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming 200 or 201 indicates success
        return true;
      } else {
        // Handle API errors
        final errorBody = json.decode(response.body);
        debugPrint(
          'Error from contact API: ${errorBody['message'] ?? 'Unknown error'}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception in ContactService: $e');
      rethrow; // Re-throw to be caught by the UI
    }
  }
}
