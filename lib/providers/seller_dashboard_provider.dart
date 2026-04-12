import 'package:flutter/material.dart';
import 'package:sungoods/models/seller_dashboard.dart';
import 'package:sungoods/services/seller_dashboard_service.dart';

class SellerDashboardProvider with ChangeNotifier {
  SellerDashboard? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  SellerDashboardService _sellerDashboardService;

  SellerDashboard? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SellerDashboardProvider(this._sellerDashboardService);

  void updateService(SellerDashboardService newService) {
    _sellerDashboardService = newService;
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _sellerDashboardService.fetchSellerDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching seller dashboard data: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashboardData() {
    _dashboardData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
