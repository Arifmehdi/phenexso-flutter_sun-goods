import 'package:flutter/foundation.dart';
import 'package:sungoods/models/cart_item.dart';
import 'package:sungoods/models/product.dart';
import 'package:sungoods/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  CartService _cartService;
  String? _guestSessionId;
  String? _previousToken;

  CartProvider(this._cartService) {
    debugPrint('CartProvider: Initialized');
    _initGuestSession().then((_) => fetchAndSetCart());
  }

  void updateService(CartService newService) {
    final newToken = newService.authToken;
    final guestId = _guestSessionId;

    // Check if user just logged in (token changed from null/empty to something)
    bool justLoggedIn =
        (newToken != null && newToken.isNotEmpty) &&
        (_previousToken == null || _previousToken!.isEmpty);

    _cartService = newService;
    _previousToken = newToken;

    if (justLoggedIn && guestId != null) {
      debugPrint('CartProvider: User just logged in, merging cart...');
      // Trigger merge without awaiting it to avoid blocking the update cycle
      _cartService
          .mergeCart()
          .then((_) {
            fetchAndSetCart();
          })
          .catchError((e) {
            debugPrint('CartProvider: Error during background merge: $e');
            fetchAndSetCart();
          });
    } else {
      fetchAndSetCart();
    }
  }

  String? get guestSessionId => _guestSessionId;

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> _initGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    _guestSessionId = prefs.getString('guest_session_id');
    if (_guestSessionId == null) {
      _guestSessionId = const Uuid().v4();
      await prefs.setString('guest_session_id', _guestSessionId!);
      debugPrint(
        'CartProvider: Generated new guest session ID: $_guestSessionId',
      );
    } else {
      debugPrint(
        'CartProvider: Loaded existing guest session ID: $_guestSessionId',
      );
    }
    // Re-initialize the service with the loaded session ID
    _cartService = CartService(_cartService.authToken, _guestSessionId);
  }

  Future<void> fetchAndSetCart() async {
    if (_cartService.authToken == null && _guestSessionId == null) {
      debugPrint(
        'CartProvider: Skipping fetch, no token or guest session ID yet.',
      );
      return;
    }
    try {
      final cartItems = await _cartService.fetchCart();
      _items.clear();
      for (var item in cartItems) {
        _items.putIfAbsent(item.product.id, () => item);
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching cart: $error');
    }
  }

  Future<void> addItem(Product product) async {
    try {
      if (_items.containsKey(product.id)) {
        final existingItem = _items[product.id]!;
        final updatedItem = await _cartService.addToCart(
          product.id,
          existingItem.quantity + 1,
        );
        _items[product.id] = updatedItem;
      } else {
        final newItem = await _cartService.addToCart(product.id, 1);
        _items.putIfAbsent(product.id, () => newItem);
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Error adding to cart: $error');
      rethrow;
    }
  }

  Future<void> increaseQuantity(String productId) async {
    if (_items.containsKey(productId)) {
      try {
        final existingItem = _items[productId]!;
        final updatedItem = await _cartService.addToCart(
          productId,
          existingItem.quantity + 1,
        );
        _items[productId] = updatedItem;
        notifyListeners();
      } catch (error) {
        debugPrint('Error increasing quantity: $error');
      }
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    try {
      final existingItem = _items[productId]!;
      if (existingItem.quantity > 1) {
        final updatedItem = await _cartService.addToCart(
          productId,
          existingItem.quantity - 1,
        );
        _items[productId] = updatedItem;
      } else {
        if (existingItem.id != null) {
          await _cartService.removeFromCart(existingItem.id!);
        }
        _items.remove(productId);
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Error decreasing quantity: $error');
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final existingItem = _items[productId];
      if (existingItem != null && existingItem.id != null) {
        await _cartService.removeFromCart(existingItem.id!);
      }
      _items.remove(productId);
      notifyListeners();
    } catch (error) {
      debugPrint('Error removing item: $error');
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
