import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sungoods/models/cart_item.dart';
import 'package:sungoods/models/product.dart';
import 'package:sungoods/utils/api_constants.dart';

class CartService {
  final String? _authToken;
  final String? _guestSessionId;

  CartService(this._authToken, [this._guestSessionId]);

  String? get authToken => _authToken;
  String? get guestSessionId => _guestSessionId;

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    // Mobile apps don't handle cookies automatically, so we send the session ID as a header.
    // The backend might need to be adjusted to look for this header.
    if (_guestSessionId != null) {
      headers['X-Session-ID'] = _guestSessionId;
    }
    return headers;
  }

  Future<List<CartItem>> fetchCart() async {
    debugPrint('CartService: Fetching cart from ${ApiConstants.cartEndpoint}');

    // Some backends might expect session_id as a query parameter for GET requests
    final uri = Uri.parse(ApiConstants.cartEndpoint).replace(
      queryParameters: _authToken == null && _guestSessionId != null
          ? {'session_id': _guestSessionId}
          : null,
    );

    final response = await http.get(uri, headers: _getHeaders());

    debugPrint('CartService: Fetch response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> itemsJson = data['data'] ?? [];
      return itemsJson.map((item) {
        return CartItem(
          id: item['id'].toString(),
          product: Product.fromJson(item['product']),
          quantity: item['quantity'],
        );
      }).toList();
    } else if (response.statusCode == 401) {
      debugPrint(
        'CartService: Unauthorized access (401). Token: $_authToken, Session: $_guestSessionId',
      );
      return [];
    } else {
      throw Exception('Failed to load cart: ${response.statusCode}');
    }
  }

  Future<CartItem> addToCart(String productId, int quantity) async {
    debugPrint(
      'CartService: Adding product $productId to cart. Token: $_authToken, Session: $_guestSessionId',
    );

    final Map<String, dynamic> body = {
      'product_id': productId,
      'quantity': quantity,
    };

    // Include session_id in the body if not authenticated
    if (_authToken == null && _guestSessionId != null) {
      body['session_id'] = _guestSessionId;
    }

    final response = await http.post(
      Uri.parse(ApiConstants.cartEndpoint),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    debugPrint('CartService: Add response status: ${response.statusCode}');
    debugPrint('CartService: Add response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final itemJson = data['data'] ?? data;
      return CartItem(
        id: itemJson['id'].toString(),
        product: Product.fromJson(itemJson['product']),
        quantity: itemJson['quantity'],
      );
    } else {
      throw Exception(
        'Failed to add to cart: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  Future<void> removeFromCart(String cartId) async {
    debugPrint('CartService: Removing cart item $cartId');
    final response = await http.delete(
      Uri.parse('${ApiConstants.cartEndpoint}/$cartId'),
      headers: _getHeaders(),
    );

    debugPrint('CartService: Remove response status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }

  Future<void> mergeCart() async {
    if (_authToken == null || _guestSessionId == null) {
      return;
    }

    debugPrint(
      'CartService: Merging guest cart ($_guestSessionId) with user account',
    );

    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.cartEndpoint}/merge'),
        headers: _getHeaders(),
        body: json.encode({'session_id': _guestSessionId}),
      );

      debugPrint('CartService: Merge response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint(
          'CartService: Merge failed but ignoring to allow user to continue: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('CartService: Error merging cart: $e');
    }
  }
}
