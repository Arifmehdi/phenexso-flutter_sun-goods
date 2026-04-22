import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/screens/chat_screen.dart';
import 'package:sungoods/providers/admin_user_provider.dart';
import 'package:sungoods/providers/product_provider.dart';
import 'package:sungoods/providers/order_provider.dart';
import 'package:sungoods/screens/profile_edit_screen.dart';
import 'package:sungoods/screens/password_change_screen.dart';
import 'package:sungoods/screens/contact_support_screen.dart';
import 'package:sungoods/screens/slider_management_screen.dart';
import 'package:sungoods/screens/banner_management_screen.dart';
import 'package:sungoods/providers/slider_provider.dart';
import 'package:sungoods/widgets/user_header.dart';
import 'package:intl/intl.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 5; // Default to Dashboard (index 5)

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        // Fetch initial data for dashboard metrics
        Provider.of<AdminUserProvider>(
          context,
          listen: false,
        ).fetchAllUsers(page: 1);
        Provider.of<ProductProvider>(
          context,
          listen: false,
        ).fetchProducts(clearProducts: true);
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchAndSetAllOrders();
      }
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    const SizedBox.shrink(), // Index 0: Home (navigates away)
    const UserManagementScreen(),
    const ProductManagementScreen(),
    const OrderManagementScreen(),
    const ChatScreen(),
    const AdminHomeScreen(), // Index 5: Dashboard
    const SliderManagementScreen(), // Index 6: Slider Management
    const BannerManagementScreen(), // Index 7: Banner Management
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 5 ? 'Admin Dashboard' : 'Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex > 5 ? 5 : _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name[0].toUpperCase() ?? 'A',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.name ?? 'Admin',
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
            selected: selectedIndex == 5,
            onTap: () {
              Navigator.pop(context);
              onTabChange(5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onTabChange(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Manage Products'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onTabChange(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Manage Orders'),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onTabChange(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onTabChange(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Slider Management'),
            selected: selectedIndex == 6,
            onTap: () {
              Navigator.pop(context);
              onTabChange(6);
            },
          ),
          ListTile(
            leading: const Icon(Icons.ad_units),
            title: const Text('Banner Management'),
            selected: selectedIndex == 7,
            onTap: () {
              Navigator.pop(context);
              onTabChange(7);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PasswordChangeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  final bool isEmbedded;
  const AdminHomeScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<AdminUserProvider>(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEmbedded) ...[const UserHeader(), const SizedBox(height: 24)],
        const Text(
          'Admin Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildMetricCard(
              context,
              'Total Users',
              userProvider.totalUsers.toString(),
              Icons.people,
            ),
            _buildMetricCard(
              context,
              'Total Products',
              productProvider.products.length.toString(),
              Icons.shopping_basket,
            ),
            _buildMetricCard(
              context,
              'Total Orders',
              orderProvider.allOrders.length.toString(),
              Icons.receipt,
            ),
            _buildMetricCard(
              context,
              'Revenue',
              '৳${orderProvider.allOrders.fold(0.0, (sum, item) => sum + item.grandTotal).toStringAsFixed(0)}',
              Icons.attach_money,
            ),
          ],
        ),
      ],
    );

    if (isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: content,
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adminUserProvider = Provider.of<AdminUserProvider>(
      context,
      listen: false,
    );
    if (!adminUserProvider.isLoading &&
        adminUserProvider.users.isEmpty &&
        adminUserProvider.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adminUserProvider.fetchAllUsers(page: 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AdminUserProvider>(
        builder: (context, adminUserProvider, child) {
          if (adminUserProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminUserProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${adminUserProvider.errorMessage}'),
            );
          }
          if (adminUserProvider.users.isEmpty &&
              adminUserProvider.currentPage == 0) {
            return const Center(child: Text('No users found.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Users: ${adminUserProvider.totalUsers}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Showing: ${adminUserProvider.users.length}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: adminUserProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = adminUserProvider.users[index];
                    final String roleName = user.role
                        .toString()
                        .split('.')
                        .last
                        .toUpperCase();
                    final bool isApproved = user.is_approve == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              (user.image != null && user.image!.isNotEmpty)
                              ? NetworkImage(
                                  '${ApiConstants.baseUrl}/storage/${user.image}',
                                )
                              : null,
                          child: (user.image == null || user.image!.isEmpty)
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 16),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isApproved ? 'APPROVED' : 'PENDING',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isApproved
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.email,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Role: $roleName',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (user.mobile != null && user.mobile!.isNotEmpty)
                              Text(
                                'Mob: ${user.mobile}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildCompactActionIcon(
                                icon: Icons.edit,
                                color: Colors.blue,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Edit ${user.name}'),
                                      ),
                                    ),
                              ),
                              _buildCompactActionIcon(
                                icon: isApproved
                                    ? Icons.block
                                    : Icons.check_circle,
                                color: isApproved
                                    ? Colors.orange
                                    : Colors.green,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isApproved
                                              ? 'Suspend ${user.name}'
                                              : 'Approve ${user.name}',
                                        ),
                                      ),
                                    ),
                              ),
                              _buildCompactActionIcon(
                                icon: Icons.delete,
                                color: Colors.red,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delete ${user.name}'),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: adminUserProvider.hasMore
                    ? (adminUserProvider.isFetchingMore
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () =>
                                  adminUserProvider.fetchNextPage(),
                              child: const Text('Load More'),
                            ))
                    : const Text(
                        'No more users to load',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts(clearProducts: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading:
                          product.imageUrls.isNotEmpty &&
                              !product.imageUrls[0].contains('placeholder')
                          ? Image.network(
                              product.imageUrls[0],
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.image),
                            )
                          : const Icon(Icons.image, size: 45),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price: ৳${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Stock: ${product.stock}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildCompactActionIcon(
                              icon: Icons.edit,
                              color: Colors.blue,
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Edit ${product.name}'),
                                    ),
                                  ),
                            ),
                            _buildCompactActionIcon(
                              icon: Icons.delete,
                              color: Colors.red,
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Delete ${product.name}'),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (provider.hasMore)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: provider.isFetchingMore
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => provider.fetchNextPage(),
                        child: const Text('Load More'),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchAndSetAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.allOrders.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAndSetAllOrders(),
          child: ListView.builder(
            itemCount: provider.allOrders.length,
            itemBuilder: (context, index) {
              final order = provider.allOrders[index];
              final String status = order.paymentStatus.toUpperCase();
              final bool isPaid = order.paymentStatus.toLowerCase() == 'paid';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.receipt,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${order.name}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Total: ৳${order.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.productName} x ${item.quantity}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    '৳${item.totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '৳${order.grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Shipping Details:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Address: ${order.addressTitle}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Mobile: ${order.mobile}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (order.email != null)
                            Text(
                              'Email: ${order.email}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (order.orderNote != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Note: ${order.orderNote}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildCompactActionIcon(
                                icon: Icons.edit,
                                color: Colors.blue,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Update Status Tapped'),
                                      ),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              _buildCompactActionIcon(
                                icon: Icons.local_shipping,
                                color: Colors.orange,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ship Order Tapped'),
                                      ),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              _buildCompactActionIcon(
                                icon: Icons.delete,
                                color: Colors.red,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cancel Order Tapped'),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Category Management Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class MoreAdminOptionsScreen extends StatelessWidget {
  const MoreAdminOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'More Admin Options (e.g., Settings, Reports)',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

Widget _buildCompactActionIcon({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}
