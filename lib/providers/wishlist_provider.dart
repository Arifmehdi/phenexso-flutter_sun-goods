import 'package:flutter/material.dart';
import 'package:sungoods/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistProvider with ChangeNotifier {
  List<Product> _wishlistItems = [];

  List<Product> get wishlistItems => _wishlistItems;

  WishlistProvider() {
    _loadWishlist();
  }

  void _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? wishlistJson = prefs.getStringList('wishlist');
    if (wishlistJson != null) {
      _wishlistItems = wishlistJson
          .map((item) => Product.fromJson(json.decode(item)))
          .toList();
      notifyListeners();
    }
  }

  void _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> wishlistJson =
        _wishlistItems.map((item) => json.encode(item.toJson())).toList();
    prefs.setStringList('wishlist', wishlistJson);
  }

  bool isInWishlist(Product product) {
    return _wishlistItems.any((item) => item.id == product.id);
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      _wishlistItems.removeWhere((item) => item.id == product.id);
    } else {
      _wishlistItems.add(product);
    }
    _saveWishlist();
    notifyListeners();
  }

  void removeItem(Product product) {
    _wishlistItems.removeWhere((item) => item.id == product.id);
    _saveWishlist();
    notifyListeners();
  }
}
