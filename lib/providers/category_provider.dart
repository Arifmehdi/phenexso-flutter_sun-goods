import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart'; // Import the new Category model

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // No initial fetch here, as categories might not always be needed immediately on app start
  // Instead, call fetchCategories() when needed, e.g., on the All Categories screen.

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        // Assuming an API endpoint for categories based on table.txt
        Uri.parse('https://hublibd.com/api/product-categories'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> categoryJsonList = responseData['data'];
          _categories = categoryJsonList
              .map((json) => Category.fromJson(json))
              .toList();
        } else {
          _errorMessage =
              'Failed to parse categories: "data" key not found or not a list.';
        }
      } else {
        _errorMessage = 'Failed to load categories: ${response.statusCode}';
      }
    } catch (error) {
      _errorMessage = 'Error fetching categories: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}