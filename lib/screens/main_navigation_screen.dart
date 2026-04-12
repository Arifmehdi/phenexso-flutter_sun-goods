import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/models/user_role.dart';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';

import 'package:sungoods/screens/product_list_screen.dart';
import 'package:sungoods/screens/rider_panel_screen.dart';
import 'package:sungoods/screens/cart_screen.dart';
import 'package:sungoods/screens/admin_panel_screen.dart';
import 'package:sungoods/screens/seller_panel_screen.dart';
import 'package:sungoods/screens/buyer_panel_screen.dart';
import 'package:sungoods/screens/login_screen.dart';
import 'package:sungoods/screens/order_history_screen.dart';
import 'package:sungoods/screens/wishlist_screen.dart';
import 'package:sungoods/screens/profile_edit_screen.dart';
import 'package:sungoods/screens/password_change_screen.dart';
import 'package:sungoods/screens/contact_support_screen.dart';
import 'package:sungoods/widgets/user_header.dart';

// Placeholder screens for other bottom nav items
class RfqScreen extends StatelessWidget {
  const RfqScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('RFQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: const Center(child: Text('RFQ Screen Content')),
    );
  }
}

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Shipping'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: const Center(child: Text('Shipping Screen Content')),
    );
  }
}

class AccountScreenWrapper extends StatelessWidget {
  final Function(int)? onTabChange;
  const AccountScreenWrapper({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (authProvider.user!.role == UserRole.buyer ||
        authProvider.user!.role == UserRole.user) {
      return BuyerPanelScreen(onTabChange: onTabChange);
    }

    return const RoleDashboardLauncher();
  }
}

class RoleDashboardLauncher extends StatelessWidget {
  const RoleDashboardLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user!;
    final bool isRider = user.role == UserRole.rider;
    final bool isSeller = user.role == UserRole.seller;
    final String roleName = user.role.toString().split('.').last.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: isRider
          ? const RiderDrawer(selectedIndex: 4, onTabChange: _dummyTabChange)
          : (isSeller
                ? SellerDrawer(selectedIndex: 5, onTabChange: (_) {})
                : (user.role == UserRole.admin
                      ? AdminDrawer(selectedIndex: 5, onTabChange: (_) {})
                      : null)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const UserHeader(),
          const SizedBox(height: 30),
          if (isRider)
            const RiderDashboardHome(isEmbedded: true)
          else if (isSeller)
            const SellerHomeScreen(isEmbedded: true)
          else if (user.role == UserRole.admin)
            const AdminHomeScreen(isEmbedded: true)
          else ...[
            Card(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: Text(
                  'Go to $roleName Dashboard',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
                onTap: () {
                  String route = '/';
                  if (user.role == UserRole.admin) {
                    route = '/admin-panel';
                  } else if (user.role == UserRole.seller)
                    route = '/seller-panel';
                  else if (user.role == UserRole.rider)
                    route = '/rider-panel';

                  Navigator.of(context).pushNamed(route);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => authProvider.logout(),
            ),
          ],
        ],
      ),
    );
  }

  static void _dummyTabChange(int index) {
    // No-op for dummy tab change
  }
}

class MainNavigationScreen extends StatefulWidget {
  static const routeName = '/'; // Set this as the initial route

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (index == 4 && authProvider.isAuthenticated) {
      if (authProvider.user!.role == UserRole.seller) {
        Navigator.of(context).pushNamed('/seller-panel');
        return;
      }
      if (authProvider.user!.role == UserRole.rider) {
        Navigator.of(context).pushNamed('/rider-panel');
        return;
      }
      if (authProvider.user!.role == UserRole.admin) {
        Navigator.of(context).pushNamed('/admin-panel');
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
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
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isBuyer =
        authProvider.isAuthenticated &&
        (authProvider.user!.role == UserRole.buyer ||
            authProvider.user!.role == UserRole.user);

    // Dynamic screens based on role
    final List<Widget> screens = isBuyer
        ? [
            const ProductListScreen(),
            const OrderHistoryScreen(),
            const WishlistScreen(),
            const CartScreen(),
            AccountScreenWrapper(onTabChange: _onItemTapped),
          ]
        : [
            const ProductListScreen(),
            const RfqScreen(),
            const CartScreen(),
            const ShippingScreen(),
            AccountScreenWrapper(onTabChange: _onItemTapped),
          ];

    // Dynamic items based on role
    final List<BottomNavigationBarItem> navItems = isBuyer
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
            _buildCartItem(),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'RFQ',
            ),
            _buildCartItem(),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Shipping',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ];

    // Ensure _selectedIndex is within bounds if role changes
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      drawer: isBuyer
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            authProvider.user?.name[0].toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          authProvider.user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authProvider.user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt),
                    title: const Text('Order History'),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('My Wishlist'),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('My Cart'),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(3);
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
                    leading: const Icon(Icons.support_agent),
                    title: const Text('Contact Support'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ContactSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  BottomNavigationBarItem _buildCartItem() {
    return BottomNavigationBarItem(
      icon: Consumer<CartProvider>(
        builder: (context, cart, child) => Stack(
          children: [
            const Icon(Icons.shopping_cart),
            if (cart.itemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cart.itemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: 'Cart',
    );
  }
}
