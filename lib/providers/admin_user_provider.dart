// lib/providers/admin_user_provider.dart
import 'package:flutter/material.dart';
import 'package:sungoods/models/user.dart'; // General app User model
import 'package:sungoods/services/admin_user_service.dart';

class AdminUserProvider with ChangeNotifier {
  final AdminUserService _adminUserService;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _lastPage = 1;
  int _totalUsers = 0;
  bool _isFetchingMore = false;

  AdminUserProvider(this._adminUserService);

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalUsers => _totalUsers;
  bool get hasMore => _currentPage < _lastPage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAllUsers({int page = 1, bool clearUsers = true}) async {
    if (_isLoading || _isFetchingMore) return;

    if (clearUsers) {
      _isLoading = true;
      _users = [];
    } else {
      _isFetchingMore = true;
    }
    
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _adminUserService.fetchAllUsers(page: page);

      final List<User> newUsers = (responseData['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      
      if (clearUsers) {
        _users = newUsers;
      } else {
        _users.addAll(newUsers);
      }

      // Laravel Resources usually place pagination in 'meta' or at root. 
      // Let's handle both.
      final Map<String, dynamic> meta = responseData['meta'] ?? responseData;
      _currentPage = meta['current_page'] ?? 1;
      _lastPage = meta['last_page'] ?? 1;
      _totalUsers = meta['total'] ?? 0;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void fetchNextPage() {
    if (hasMore) {
      fetchAllUsers(page: _currentPage + 1, clearUsers: false);
    }
  }

  void resetUsers() {
    _users = [];
    _currentPage = 0;
    _lastPage = 1;
    _totalUsers = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
