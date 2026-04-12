import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';

class OrderService {
  final String? _authToken;
  final String? _guestSessionId;

  OrderService(this._authToken, [this._guestSessionId]);

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (_guestSessionId != null) {
      headers['X-Session-ID'] = _guestSessionId;
    }
    return headers;
  }

  Future<Map<String, dynamic>> placeOrder({
    required String name,
    required String mobile,
    String? email,
    required String addressTitle,
    required String paymentMethod,
    String? orderNote,
  }) async {
    debugPrint('OrderService: Placing order for $name');

    final Map<String, dynamic> body = {
      'name': name,
      'mobile': mobile,
      'email': email,
      'address_title': addressTitle,
      'payment_method': paymentMethod,
      'order_note': orderNote,
    };

    if (_authToken == null && _guestSessionId != null) {
      body['session_id'] = _guestSessionId;
    }

    final response = await http.post(
      Uri.parse(ApiConstants.ordersEndpoint),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    debugPrint(
      'OrderService: Place order response status: ${response.statusCode}',
    );
    debugPrint('OrderService: Place order response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to place order: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  Future<List<dynamic>> fetchOrders() async {
    debugPrint(
      'OrderService: Fetching orders from ${ApiConstants.ordersEndpoint}',
    );
    debugPrint('OrderService: Using Headers: ${_getHeaders()}');

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.ordersEndpoint),
        headers: _getHeaders(),
      );

      debugPrint(
        'OrderService: Fetch orders response status: ${response.statusCode}',
      );
      debugPrint('OrderService: Fetch orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Laravel Resources with pagination usually wrap items in 'data'
        final List<dynamic> orders = data['data'] ?? [];
        debugPrint('OrderService: Successfully parsed ${orders.length} orders');
        return orders;
      } else {
        debugPrint('OrderService: Error response - ${response.body}');
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OrderService: Exception during fetchOrders: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchAllOrders() async {
    debugPrint(
      'OrderService: Fetching all orders from ${ApiConstants.allOrdersEndpoint}',
    );

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.allOrdersEndpoint),
        headers: _getHeaders(),
      );

      debugPrint(
        'OrderService: Fetch all orders response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // If data is a List directly, return it. If it's wrapped in 'data' key, extract it.
        if (data['data'] is List) {
          return data['data'];
        }
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch all orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OrderService: Exception during fetchAllOrders: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchSellerOrders() async {
    debugPrint(
      'OrderService: Fetching seller orders from ${ApiConstants.sellerOrdersEndpoint}',
    );

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.sellerOrdersEndpoint),
        headers: _getHeaders(),
      );

      debugPrint(
        'OrderService: Fetch seller orders response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> orders = data['data'] ?? [];
        return orders;
      } else {
        throw Exception(
          'Failed to fetch seller orders: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('OrderService: Exception during fetchSellerOrders: $e');
      rethrow;
    }
  }
}
