import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart'; // Adjust the import path as necessary
import '../utils/api_constants.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = []; // Main list (Home)
  List<Product> _categoryProducts = []; // Category-specific list
  List<Product> _featuredProducts = []; // Featured products
  
  bool _isLoading = false;
  bool _isFeaturedLoading = false;
  bool _isCategoryLoading = false;
  
  String? _errorMessage;
  
  // Home pagination
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  
  // Category pagination
  int _categoryCurrentPage = 1;
  bool _categoryHasMore = true;
  bool _isCategoryFetchingMore = false;

  List<Product> get products => _products;
  List<Product> get categoryProducts => _categoryProducts;
  List<Product> get featuredProducts => _featuredProducts;
  
  bool get isLoading => _isLoading;
  bool get isFeaturedLoading => _isFeaturedLoading;
  bool get isCategoryLoading => _isCategoryLoading;
  
  String? get errorMessage => _errorMessage;
  
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  
  bool get categoryHasMore => _categoryHasMore;
  bool get isCategoryFetchingMore => _isCategoryFetchingMore;

  int get totalProducts => _products.length;
  int get pageSize => _pageSize;

  ProductProvider();

  Future<void> fetchFeaturedProducts() async {
    _isFeaturedLoading = true;
    notifyListeners();

    try {
      final url = '${ApiConstants.baseUrl}/api/products';
      final uri = Uri.parse(url).replace(queryParameters: {
        'per_page': '100', // Fetch more to find featured ones
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> productJsonList = responseData['data'];
          final List<Product> fetchedProducts =
              productJsonList.map((json) => Product.fromJson(json)).toList();
          
          _featuredProducts = fetchedProducts.where((p) => p.active == 1 && p.featured == 1).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching featured products: $error');
    } finally {
      _isFeaturedLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({int page = 1, bool clearProducts = true}) async {
    if (clearProducts) {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
      _products = [];
      notifyListeners();
    } else if (!_hasMore || _isFetchingMore) {
      return;
    }

    _isFetchingMore = true;
    try {
      final url = '${ApiConstants.baseUrl}/api/products';
      final uri = Uri.parse(url).replace(queryParameters: {
        'page': page.toString(),
        'per_page': _pageSize.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> productJsonList = responseData['data'];
          final List<Product> fetchedProducts =
              productJsonList.map((json) => Product.fromJson(json)).toList();
          
          final List<Product> newProducts = fetchedProducts.where((p) => p.active == 1).toList();

          if (clearProducts) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }

          if (responseData['meta'] != null) {
            int lastPage = responseData['meta']['last_page'] ?? 1;
            _hasMore = page < lastPage;
          } else {
            _hasMore = fetchedProducts.length == _pageSize;
          }
          _currentPage = page;
        }
      } else {
        _errorMessage = 'Failed to load products';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategoryProducts({required String categorySlug, int page = 1, bool clearProducts = true}) async {
    if (clearProducts) {
      _isCategoryLoading = true;
      _errorMessage = null;
      _categoryCurrentPage = 1;
      _categoryHasMore = true;
      _categoryProducts = [];
      notifyListeners();
    } else if (!_categoryHasMore || _isCategoryFetchingMore) {
      return;
    }

    _isCategoryFetchingMore = true;
    try {
      final url = '${ApiConstants.baseUrl}/api/products/by-slug/$categorySlug';
      final uri = Uri.parse(url).replace(queryParameters: {
        'page': page.toString(),
        'per_page': _pageSize.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> productJsonList = responseData['data'];
          final List<Product> fetchedProducts =
              productJsonList.map((json) => Product.fromJson(json)).toList();
          
          final List<Product> newProducts = fetchedProducts.where((p) => p.active == 1).toList();

          if (clearProducts) {
            _categoryProducts = newProducts;
          } else {
            _categoryProducts.addAll(newProducts);
          }

          if (responseData['meta'] != null) {
            int lastPage = responseData['meta']['last_page'] ?? 1;
            _categoryHasMore = page < lastPage;
          } else {
            _categoryHasMore = fetchedProducts.length == _pageSize;
          }
          _categoryCurrentPage = page;
        }
      }
    } catch (error) {
      debugPrint('Error fetching category products: $error');
    } finally {
      _isCategoryLoading = false;
      _isCategoryFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    await fetchProducts(page: _currentPage + 1, clearProducts: false);
  }

  Future<void> fetchNextCategoryPage(String categorySlug) async {
    await fetchCategoryProducts(categorySlug: categorySlug, page: _categoryCurrentPage + 1, clearProducts: false);
  }

  void resetProducts() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
