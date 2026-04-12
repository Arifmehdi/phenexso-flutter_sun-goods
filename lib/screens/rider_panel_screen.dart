import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/screens/rider_chat_users_screen.dart';
import 'package:sungoods/screens/profile_edit_screen.dart';
import 'package:sungoods/screens/password_change_screen.dart';
import 'package:sungoods/providers/rider_dashboard_provider.dart';
import 'package:sungoods/models/order.dart';
import 'package:sungoods/widgets/user_header.dart';
import 'package:intl/intl.dart';
import 'package:sungoods/screens/rider_order_detail_screen.dart';

import 'package:sungoods/widgets/custom_app_bar.dart';

class RiderPanelScreen extends StatefulWidget {
  const RiderPanelScreen({super.key});

  @override
  State<RiderPanelScreen> createState() => _RiderPanelScreenState();
}

class _RiderPanelScreenState extends State<RiderPanelScreen> {
  int _selectedIndex = 4; // Initialized to Account (index 4)

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Rider Panel';
    if (_selectedIndex == 4) title = 'Rider Dashboard';
    if (_selectedIndex == 1) title = 'Active Orders';
    if (_selectedIndex == 2) title = 'Order History';
    if (_selectedIndex == 3) title = 'Messages';

    final List<Widget> widgetOptions = <Widget>[
      const SizedBox.shrink(), // Index 0 is Home
      const ActiveOrdersScreen(), // Index 1
      const HistoryScreen(), // Index 2
      const RiderChatUsersScreen(), // Index 3
      RiderDashboardHome(onTabChange: _onItemTapped), // Index 4
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showDrawerButton: true,
        showSearchBar: false,
      ),
      drawer: RiderDrawer(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Active',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class RiderDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const RiderDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final riderDashboardProvider = Provider.of<RiderDashboardProvider>(
      context,
      listen: false,
    );
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        await authProvider.logout();
        riderDashboardProvider.clearDashboardData();
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      authProvider.user?.image != null
                          ? NetworkImage(authProvider.user!.image!)
                          : null,
                  child:
                      authProvider.user?.image == null
                          ? Text(
                            authProvider.user?.name[0].toUpperCase() ?? 'R',
                          )
                          : null,
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.name ?? 'Rider',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onTabChange(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delivery_dining),
            title: const Text('Active Orders'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              Provider.of<RiderDashboardProvider>(
                context,
                listen: false,
              ).setStatusFilter('All');
              onTabChange(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('All Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AllOrdersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              Provider.of<RiderDashboardProvider>(
                context,
                listen: false,
              ).setStatusFilter('All');
              onTabChange(2);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PasswordChangeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class RiderDashboardHome extends StatefulWidget {
  final bool isEmbedded;
  final Function(int)? onTabChange;
  const RiderDashboardHome({super.key, this.isEmbedded = false, this.onTabChange});

  @override
  State<RiderDashboardHome> createState() => _RiderDashboardHomeState();
}

class _RiderDashboardHomeState extends State<RiderDashboardHome> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => Provider.of<RiderDashboardProvider>(
        context,
        listen: false,
      ).fetchDashboardData(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });
  }

  void _handleStatTap(String status) {
    if (status == 'All') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AllOrdersScreen(),
        ),
      );
      return;
    }

    if (widget.onTabChange == null) return;

    final provider = Provider.of<RiderDashboardProvider>(context, listen: false);

    if (status == 'delivered') {
      provider.setStatusFilter('delivered');
      widget.onTabChange!(2); // Order History
    } else {
      provider.setStatusFilter(status);
      widget.onTabChange!(1); // Active Orders
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RiderDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.dashboardData == null) {
          return const Center(child: Text('No data available'));
        }

        final data = provider.dashboardData!;
        final stats = data.stats;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEmbedded) ...[
              const UserHeader(),
              const SizedBox(height: 20),
              const Text(
                'Statistics Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Orders',
                  stats.totalOrders.toString(),
                  Icons.assignment,
                  Colors.blue,
                  onTap: () => _handleStatTap('All'),
                ),
                _buildStatCard(
                  'Pending',
                  stats.pendingOrders.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                  onTap: () => _handleStatTap('pending'),
                ),
                _buildStatCard(
                  'Shipped',
                  stats.shippedOrders.toString(),
                  Icons.local_shipping,
                  Colors.purple,
                  onTap: () => _handleStatTap('shipped'),
                ),
                _buildStatCard(
                  'Delivered',
                  stats.deliveredOrders.toString(),
                  Icons.check_circle,
                  Colors.green,
                  onTap: () => _handleStatTap('delivered'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (data.recentOrders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent orders'),
                ),
              )
            else
              ...data.recentOrders.map(
                (order) => _buildOrderTile(context, order),
              ),
          ],
        );

        if (widget.isEmbedded) {
          return content;
        }

        return Scaffold(
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
          floatingActionButton: _showBackToTop
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  mini: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('Order #${order.id}'),
        subtitle: Text(
          'Status: ${order.paymentStatus}\nTotal: ৳${order.grandTotal.toStringAsFixed(2)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RiderOrderDetailScreen(order: order),
            ),
          );
        },
      ),
    );
  }
}

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  final Map<String, TextEditingController> _noteControllers = {};
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => Provider.of<RiderDashboardProvider>(
        context,
        listen: false,
      ).fetchActiveOrders(),
    );
  }

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });
  }

  TextEditingController _getController(String orderId) {
    if (!_noteControllers.containsKey(orderId)) {
      _noteControllers[orderId] = TextEditingController();
    }
    return _noteControllers[orderId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RiderDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          
          final baseOrders = provider.activeOrders;
          
          final filteredOrders = baseOrders.where((order) {
            if (provider.selectedStatusFilter == 'All') return true;
            return order.orderStatus.toLowerCase() == provider.selectedStatusFilter.toLowerCase();
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No orders found'),
                  if (provider.selectedStatusFilter != 'All')
                    TextButton(
                      onPressed: () => provider.setStatusFilter('All'),
                      child: const Text('Show All Orders'),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchActiveOrders(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final noteController = _getController(order.id);
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RiderOrderDetailScreen(order: order),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (order.orderStatus == 'shipped'
                                              ? Colors.blue
                                              : Colors.orange)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.orderStatus.toUpperCase(),
                                  style: TextStyle(
                                    color: order.orderStatus == 'shipped'
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(Icons.person, 'Customer: ${order.name}'),
                          _buildInfoRow(Icons.phone, 'Phone: ${order.mobile}'),
                          _buildInfoRow(
                            Icons.location_on,
                            'Address: ${order.addressTitle}',
                          ),
                          _buildInfoRow(
                            Icons.payments,
                            'Amount: ৳${order.grandTotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              hintText: 'Add a note (optional)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: order.orderStatus != 'shipped'
                                    ? () => _updateStatus(
                                        context,
                                        order.id,
                                        'shipped',
                                        noteController.text,
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                ),
                                child: const Text('Shipped'),
                              ),
                              ElevatedButton(
                                onPressed: order.orderStatus == 'shipped'
                                    ? () => _updateStatus(
                                        context,
                                        order.id,
                                        'delivered',
                                        noteController.text,
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                ),
                                child: const Text('Delivered'),
                              ),
                              ElevatedButton(
                                onPressed: order.orderStatus == 'shipped'
                                    ? () => _updateStatus(
                                        context,
                                        order.id,
                                        'canceled',
                                        noteController.text,
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _updateStatus(
    BuildContext context,
    String orderId,
    String status,
    String note,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Are you sure you want to mark this order as $status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<RiderDashboardProvider>(
                  context,
                  listen: false,
                ).updateOrderStatus(orderId, status, note: note);
                // Clear the note field on success
                _noteControllers[orderId]?.clear();
              } catch (e) {
                // Error handled by provider
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => Provider.of<RiderDashboardProvider>(
        context,
        listen: false,
      ).fetchOrderHistory(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RiderDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          
          final filteredOrders = provider.orderHistory.where((order) {
            if (provider.selectedStatusFilter == 'All') return true;
            return order.orderStatus.toLowerCase() == provider.selectedStatusFilter.toLowerCase();
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No order history found'),
                  if (provider.selectedStatusFilter != 'All')
                    TextButton(
                      onPressed: () => provider.setStatusFilter('All'),
                      child: const Text('Show All Orders'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: order.paymentStatus == 'paid'
                        ? Colors.green
                        : Colors.grey,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}\nTotal: ৳${order.grandTotal.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    order.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: order.paymentStatus == 'paid'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RiderOrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All My Orders'),
      ),
      body: Consumer<RiderDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          final orders = provider.allOrders;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    'Status: ${order.orderStatus.toUpperCase()}\nDate: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}\nTotal: ৳${order.grandTotal.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RiderOrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}
