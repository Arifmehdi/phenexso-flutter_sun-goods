import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart'; // Adjust the import path as necessary
import '../utils/api_constants.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1; // Current page number for pagination
  final int _pageSize = 10; // Number of items per page
  bool _hasMore = true; // Indicates if there are more products to load
  bool _isFetchingMore = false; // Prevents multiple concurrent fetchMore calls
  int _totalProducts = 0; // Total count of products from backend

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore; // Public getter for _hasMore
  bool get isFetchingMore => _isFetchingMore; // Public getter for _isFetchingMore
  int get totalProducts => _totalProducts; // Public getter for totalProducts

  ProductProvider() {
    // fetchProducts(); // Removed: Fetching should be triggered by widget lifecycle
  }

  Future<void> fetchProducts({String? categorySlug, int page = 1, int? pageSize, bool clearProducts = true}) async {
    if (clearProducts) {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
      _products = []; // Clear products only on initial load or category change
      notifyListeners();
    } else if (!_hasMore || _isFetchingMore) {
      return; // Do not fetch if no more products or already fetching
    }

    _isFetchingMore = true; // Set fetching flag to true
    // No need to set _isLoading = true here if clearProducts is false,
    // as _isLoading is for initial full page load indicator.
    // We will show a separate indicator for fetching more.

    try {
      String url;
      if (categorySlug != null) {
        url = '${ApiConstants.baseUrl}/api/products/by-slug/$categorySlug';
      } else {
        url = '${ApiConstants.baseUrl}/api/products';
      }

      // Add pagination parameters
      final uri = Uri.parse(url).replace(queryParameters: {
        'page': page.toString(),
        'per_page': (pageSize ?? _pageSize).toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> productJsonList = responseData['data'];
          final List<Product> fetchedProducts =
              productJsonList.map((json) => Product.fromJson(json)).toList();
          
          // Filter to only include active products
          final List<Product> newProducts = fetchedProducts.where((p) => p.active == 1).toList();

          if (clearProducts) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }

          if (responseData['meta'] != null) {
            _totalProducts = responseData['meta']['total'] ?? 0;
            int lastPage = responseData['meta']['last_page'] ?? 1;
            _hasMore = page < lastPage;
          } else {
            _totalProducts = responseData['total'] ?? 0;
            _hasMore = newProducts.length == (pageSize ?? _pageSize);
          }
          
          _currentPage = page; // Update current page after successful fetch
        } else {
          _errorMessage =
              'Failed to parse products: "data" key not found or not a list.';
          _hasMore = false; // No more data if parsing fails
        }
      } else {
        _errorMessage = 'Failed to load products: ${response.statusCode}';
        _hasMore = false; // No more data on error
      }
    } catch (error) {
      _errorMessage = 'Error fetching products: $error';
      _hasMore = false; // No more data on error
    } finally {
      _isLoading = false; // Reset initial loading state
      _isFetchingMore = false; // Reset fetching flag
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategorySlug(String slug) async {
    await fetchProducts(categorySlug: slug, clearProducts: true);
  }

  Future<void> fetchNextPage({String? categorySlug}) async {
    if (!_hasMore || _isFetchingMore) {
      return;
    }
    await fetchProducts(
        categorySlug: categorySlug,
        page: _currentPage + 1,
        pageSize: _pageSize,
        clearProducts: false);
  }

  // Method to get a product by ID (useful for detail screen)
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to reset the product list and pagination state, useful for refreshing
  void resetProducts() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

// Add a fromJson factory method to your Product model
// This should ideally be in product.dart, but adding here for context
/*
extension ProductExtension on Product {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(), // Ensure id is string
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? ['assets/images/placeholder.png']), // Handle missing or null imageUrls
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // Handle missing or null rating
    );
  }
}
*/
