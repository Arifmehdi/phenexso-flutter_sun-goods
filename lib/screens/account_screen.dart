import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/models/user_role.dart'; // Import UserRole
import 'package:sungoods/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:sungoods/screens/password_change_screen.dart'; // Import PasswordChangeScreen
import 'package:sungoods/screens/rider_panel_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final bool isRider = user != null && user.role == UserRole.rider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        automaticallyImplyLeading: !isRider,
        leading: isRider
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: isRider 
          ? const RiderDrawer(selectedIndex: 4, onTabChange: _handleTabChange) 
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(user?.name ?? 'Guest'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(user?.email ?? ''),
              ),
            ),
            if (isRider) ...[
              const SizedBox(height: 16.0),
              const RiderDashboardHome(isEmbedded: true),
            ] else ...[
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PasswordChangeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Change Password'),
              ),
              if (user != null && user.role != UserRole.user) ...[
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    String route = '';
                    switch (user.role) {
                      case UserRole.admin:
                        route = '/admin-panel';
                        break;
                      case UserRole.seller:
                        route = '/seller-panel';
                        break;
                      case UserRole.rider:
                        route = '/rider-panel';
                        break;
                      default:
                        break;
                    }
                    if (route.isNotEmpty) {
                      Navigator.of(context).pushNamed(route);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text('Go to ${user.role.toString().split('.').last} Panel'),
                ),
              ],
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                ),
                child: const Text('Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void _handleTabChange(int index) {
    // Handle tab change if needed in this context
  }
}
