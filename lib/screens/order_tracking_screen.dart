import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/widgets/custom_app_bar.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:sungoods/models/user_role.dart'; // Import UserRole enum

class OrderTrackingScreen extends StatefulWidget {
  static const routeName = '/order-tracking';

  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Removed _searchController and _onSearch as search bar is removed
  final TextEditingController _orderIdController = TextEditingController();
  String _trackingStatus = "Enter an Order ID to track its status.";

  @override
  void dispose() {
    // _searchController.dispose(); // Removed as _searchController is removed
    _orderIdController.dispose();
    super.dispose();
  }

  // Removed _onSearch method as search bar is removed

  void _trackOrder() {
    String orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      setState(() {
        _trackingStatus = "Please enter a valid Order ID.";
      });
      return;
    }

    // Simulate order tracking based on dummy logic
    // In a real app, this would involve an API call
    setState(() {
      if (orderId == "12345") {
        _trackingStatus =
            "Order #$orderId: Shipped and expected to arrive by Feb 15, 2026.";
      } else if (orderId == "67890") {
        _trackingStatus = "Order #$orderId: Processing and awaiting shipment.";
      } else {
        _trackingStatus =
            "Order #$orderId: Status not found. Please check the ID.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0; // Default to Home for bottom nav consistency

    void onItemTapped(int index) {
      if (index == selectedIndex) {
        return;
      }
      setState(() {
        selectedIndex = index;
      });

      if (!mounted) return; // Add mounted check here

      switch (index) {
        case 0:
          // Navigate to home only if not already on home
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.of(context).pushReplacementNamed('/');
          }
          break;
        case 1:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RFQ Screen (Not Implemented)')),
          );
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed('/cart'); // Cart
          break;
        case 3:
          Navigator.of(
            context,
          ).pushReplacementNamed('/shipping-address'); // Shipping
          break;
        case 4:
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (!mounted) {
            return; // Re-check mounted after potentially long Provider operation
          }
          if (authProvider.isAuthenticated) {
            if (authProvider.user!.role == UserRole.admin) {
              Navigator.of(
                context,
              ).pushReplacementNamed('/admin-panel'); // Navigate to Admin Panel
            } else {
              Navigator.of(context).pushReplacementNamed(
                '/account',
              ); // Navigate to Account for other roles
            }
          } else {
            Navigator.of(
              context,
            ).pushReplacementNamed('/login'); // Navigate to Login
          }
          break;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Tracking',
        showBackButton: true,
        showSearchBar: false, // Hide search bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _orderIdController,
              decoration: InputDecoration(
                labelText: 'Order ID',
                hintText: 'e.g., 12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _orderIdController.clear();
                    setState(() {
                      _trackingStatus =
                          "Enter an Order ID to track its status.";
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _trackOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Track Order',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 24.0),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tracking Status:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _trackingStatus,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account
            label: 'Account',
          ),
        ],
        currentIndex: selectedIndex, // Will always be 0 here as per logic above
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}
