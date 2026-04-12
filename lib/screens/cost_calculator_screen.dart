import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/widgets/custom_app_bar.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:sungoods/models/user_role.dart'; // Import UserRole enum

class CostCalculatorScreen extends StatefulWidget {
  static const routeName = '/cost-calculator';

  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  // Removed _searchController and _onSearch as search bar is removed
  String _output = "0";
  String _num1 = "";
  String _num2 = "";
  String _operand = "";
  bool _clearOnNextInput = false;

  @override
  void dispose() {
    // _searchController.dispose(); // Removed as _searchController is removed
    super.dispose();
  }

  // Removed _onSearch method as search bar is removed

  void _buttonPressed(String buttonText) {
    if (buttonText == "CLEAR") {
      _output = "0";
      _num1 = "";
      _num2 = "";
      _operand = "";
      _clearOnNextInput = false;
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "×" ||
        buttonText == "÷") {
      if (_num1.isEmpty) _num1 = _output; // If no num1, use current output
      _operand = buttonText;
      _clearOnNextInput = true;
    } else if (buttonText == ".") {
      if (_clearOnNextInput) {
        _output = "0.";
        _clearOnNextInput = false;
      } else if (!_output.contains(".")) {
        _output = _output + buttonText;
      }
    } else if (buttonText == "=") {
      if (_num1.isEmpty || _operand.isEmpty || _clearOnNextInput)
        return; // Not enough info to calculate

      _num2 = _output;
      double n1 = double.parse(_num1);
      double n2 = double.parse(_num2);

      if (_operand == "+") {
        _output = (n1 + n2).toString();
      }
      if (_operand == "-") {
        _output = (n1 - n2).toString();
      }
      if (_operand == "×") {
        _output = (n1 * n2).toString();
      }
      if (_operand == "÷") {
        _output = (n1 / n2).toString();
      }

      _num1 = _output; // Result becomes the new num1
      _num2 = "";
      _operand = "";
      _clearOnNextInput = true; // Clear output for next number input
    } else {
      if (_clearOnNextInput) {
        _output = buttonText;
        _clearOnNextInput = false;
      } else {
        _output = (_output == "0") ? buttonText : _output + buttonText;
      }
    }

    setState(() {});
  }

  Widget _buildButton(
    String buttonText, {
    Color? buttonColor,
    Color? textColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                buttonColor ??
                Theme.of(context).buttonTheme.colorScheme?.primary ??
                Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            padding: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
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
          if (!mounted)
            return; // Re-check mounted after potentially long Provider operation
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
        title: 'Cost Calculator',
        showBackButton: true,
        showSearchBar: false, // Hide search bar
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton(
                    "÷",
                    buttonColor: Colors.orange,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton(
                    "×",
                    buttonColor: Colors.orange,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton(
                    "-",
                    buttonColor: Colors.orange,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton("."),
                  _buildButton("0"),
                  _buildButton("00"), // Added 00 for convenience
                  _buildButton(
                    "+",
                    buttonColor: Colors.orange,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton(
                    "CLEAR",
                    buttonColor: Colors.red,
                    textColor: Colors.white,
                  ),
                  _buildButton(
                    "=",
                    buttonColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ],
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
