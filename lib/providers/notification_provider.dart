import 'package:flutter/material.dart';
import 'package:sungoods/models/notification.dart';
import 'package:sungoods/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _token;
  late NotificationService _notificationService;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _notificationService = NotificationService(null);
    fetchNotifications();
  }

  void updateToken(String? token) {
    _token = token;
    _notificationService = NotificationService(_token);
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.fetchNotifications();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          ipAddress: _notifications[index].ipAddress,
          type: _notifications[index].type,
          allShow: _notifications[index].allShow,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllRead();
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        ipAddress: n.ipAddress,
        type: n.type,
        allShow: n.allShow,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
