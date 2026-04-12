// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:sungoods/models/chat/user.dart';
import 'package:sungoods/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._userService);

  List<User> get users => _users; // Use hubli_user.User
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _users = await _userService.fetchAllUsers();
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
