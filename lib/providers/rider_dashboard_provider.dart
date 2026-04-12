import 'package:flutter/material.dart';
import 'package:sungoods/models/rider_dashboard.dart';
import 'package:sungoods/models/order.dart';
import 'package:sungoods/services/rider_dashboard_service.dart';

class RiderDashboardProvider with ChangeNotifier {
  RiderDashboard? _dashboardData;
  List<Order> _activeOrders = [];
  List<Order> _orderHistory = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  RiderDashboardService _riderDashboardService;

  RiderDashboard? get dashboardData => _dashboardData;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get orderHistory => _orderHistory;
  
  List<Order> get allOrders {
    final Map<String, Order> orderMap = {};
    for (var order in _activeOrders) {
      orderMap[order.id] = order;
    }
    if (_dashboardData != null) {
      for (var order in _dashboardData!.recentOrders) {
        orderMap[order.id] = order;
      }
    }
    final List<Order> merged = orderMap.values.toList();
    merged.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return merged;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _selectedStatusFilter = 'All';
  String get selectedStatusFilter => _selectedStatusFilter;

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  RiderDashboardProvider(this._riderDashboardService);

  void updateService(RiderDashboardService newService) {
    _riderDashboardService = newService;
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _riderDashboardService.fetchRiderDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeOrders = await _riderDashboardService.fetchActiveOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orderHistory = await _riderDashboardService.fetchOrderHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? note}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _riderDashboardService.updateOrderStatus(orderId, status, note: note);
      // Refresh data
      await fetchActiveOrders();
      await fetchDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashboardData() {
    _dashboardData = null;
    _activeOrders = [];
    _orderHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}
