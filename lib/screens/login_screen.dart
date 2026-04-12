import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/models/user_role.dart'; // Re-add the missing import
import 'package:sungoods/screens/forgot_password_screen.dart'; // Import ForgotPasswordScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
        if (!mounted) return; // Add mounted check here

        // Navigate based on user role
        if (authProvider.user != null) {
          String routeName;
          switch (authProvider.user!.role) {
            case UserRole.admin:
              routeName = '/admin-panel';
              break;
            case UserRole.rider:
              routeName = '/rider-panel';
              break;
            case UserRole.seller:
              routeName = '/seller-panel';
              break;
            case UserRole.buyer:
            case UserRole.user:
              routeName = '/'; // Navigate to root for buyers
              break;
          }
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(routeName, (route) => false);
        }
      } catch (e) {
        if (!mounted) return; // Add mounted check here
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Handles title and icon colors
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // If it's the last route, go to the main home page
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 8.0), // Added spacing
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(ForgotPasswordScreen.routeName);
                },
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
