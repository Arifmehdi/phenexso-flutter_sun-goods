import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/models/seller_dashboard.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class SellerDashboardService {
  final String? _token;

  SellerDashboardService(this._token);

  Future<SellerDashboard> fetchSellerDashboardData() async {
    if (_token == null) {
      throw Exception('Authentication token is missing.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/seller/dashboard'); // Assuming this endpoint

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      debugPrint('Seller Dashboard API Response Status: ${response.statusCode}');
      debugPrint('Seller Dashboard API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        // Assuming the API returns a direct JSON object that matches SellerDashboard structure
        // If it's nested (e.g., {'data': {...}}), adjust here.
        return SellerDashboard.fromJson(responseData);
      } else {
        String errorMessage = 'Failed to load seller dashboard data';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          debugPrint('Error decoding seller dashboard error response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Exception in SellerDashboardService: $e');
      rethrow;
    }
  }
}
