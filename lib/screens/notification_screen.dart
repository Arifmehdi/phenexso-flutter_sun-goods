import 'package:flutter/material.dart';
import 'package:sungoods/providers/notification_provider.dart';
import 'package:sungoods/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        showSearchBar: false,
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : RefreshIndicator(
                  onRefresh: notificationProvider.fetchNotifications,
                  child: ListView.separated(
                    itemCount: notificationProvider.notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      return ListTile(
                        tileColor: notification.isRead
                            ? null
                            : Colors.blue.withOpacity(0.05),
                        leading: CircleAvatar(
                          backgroundColor: notification.isRead
                              ? Colors.grey[200]
                              : Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.notifications,
                            color: notification.isRead
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.message,
                              style: TextStyle(
                                color: notification.isRead
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, h:mm a').format(notification.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!notification.isRead) {
                            notificationProvider.markAsRead(notification.id);
                          }
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: notificationProvider.unreadCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => notificationProvider.markAllAsRead(),
              label: const Text('Mark all as read'),
              icon: const Icon(Icons.done_all),
            )
          : null,
    );
  }
}
