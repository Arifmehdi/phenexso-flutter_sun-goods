import 'package:flutter/material.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sungoods/models/user_role.dart'; // Import UserRole enum

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  int _selectedIndex = 0; // Initialize to Home index

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });

    if (!mounted) return; // Add mounted check here

    // Handle navigation based on index
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
        Navigator.of(context).pushReplacementNamed('/shipping-address'); // Shipping
        break;
      case 4:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!mounted) return; // Re-check mounted after potentially long Provider operation
        if (authProvider.isAuthenticated) {
          if (authProvider.user!.role == UserRole.admin) {
            Navigator.of(context).pushReplacementNamed('/admin-panel'); // Navigate to Admin Panel
          } else {
            Navigator.of(context).pushReplacementNamed('/account'); // Navigate to Account for other roles
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login'); // Navigate to Login
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Handles title and icon colors
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Confirm Order'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      NumberFormat.currency(locale: 'en_BD', symbol: '৳ ').format(cart.totalAmount),
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final cartItem = cart.items.values.toList()[i];
                return ListTile(
                  title: Text(cartItem.product.name),
                  subtitle: Text('Quantity: ${cartItem.quantity}'),
                  trailing: Text('৳${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}