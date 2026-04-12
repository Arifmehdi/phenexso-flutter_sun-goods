import 'package:flutter/foundation.dart';
import 'package:sungoods/models/order.dart';
import 'package:sungoods/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _allOrders = [];
  List<Order> _sellerOrders = [];
  final OrderService _orderService;
  bool _isLoading = false;
  bool _didFetchInitialData = false;

  OrderProvider(this._orderService);

  List<Order> get orders => [..._orders];
  List<Order> get allOrders => [..._allOrders];
  List<Order> get sellerOrders => [..._sellerOrders];
  bool get isLoading => _isLoading;
  bool get didFetchInitialData => _didFetchInitialData;

  Future<void> fetchAndSetOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> fetchedData = await _orderService.fetchOrders();
      debugPrint('OrderProvider: Mapping ${fetchedData.length} items to Order models');
      
      _orders = fetchedData.map((item) {
        try {
          return Order.fromJson(item);
        } catch (e) {
          debugPrint('OrderProvider: Error mapping individual order: $e. Item data: $item');
          return null;
        }
      })
      .where((order) => order != null)
      .cast<Order>()
      .toList();
      
      _didFetchInitialData = true;
      debugPrint('OrderProvider: Final order count in provider: ${_orders.length}');
    } catch (error) {
      debugPrint('OrderProvider: Error fetching orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> fetchedData = await _orderService.fetchAllOrders();
      _allOrders = fetchedData.map((item) {
        try {
          return Order.fromJson(item);
        } catch (e) {
          debugPrint('OrderProvider: Error mapping individual order from all: $e');
          return null;
        }
      })
      .where((order) => order != null)
      .cast<Order>()
      .toList();
      
      // Also update _orders if this is used in contexts where _orders is expected
      // But keeping them separate is safer. 
      // For simplicity in UI reuse, we might want to also assign it to _orders 
      // or make the UI use allOrders.
    } catch (error) {
      debugPrint('OrderProvider: Error fetching all orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder({
    required String name,
    required String mobile,
    String? email,
    required String addressTitle,
    required String paymentMethod,
    String? orderNote,
  }) async {
    try {
      await _orderService.placeOrder(
        name: name,
        mobile: mobile,
        email: email,
        addressTitle: addressTitle,
        paymentMethod: paymentMethod,
        orderNote: orderNote,
      );
      
      // Refresh the orders list
      await fetchAndSetOrders();
    } catch (error) {
      debugPrint('OrderProvider: Error adding order: $error');
      rethrow;
    }
  }

  Future<void> fetchAndSetSellerOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> fetchedData = await _orderService.fetchSellerOrders();
      _sellerOrders = fetchedData.map((item) {
        try {
          return Order.fromJson(item);
        } catch (e) {
          debugPrint('OrderProvider: Error mapping individual seller order: $e');
          return null;
        }
      })
      .where((order) => order != null)
      .cast<Order>()
      .toList();
    } catch (error) {
      debugPrint('OrderProvider: Error fetching seller orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
