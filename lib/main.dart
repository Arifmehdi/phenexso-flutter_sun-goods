import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sungoods/utils/colors.dart';
import 'package:sungoods/screens/product_detail_screen.dart';
import 'package:sungoods/screens/cart_screen.dart';
import 'package:sungoods/models/product.dart'; // Import Product model for ProductDetailScreen arguments
import 'package:provider/provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:sungoods/providers/order_provider.dart';
import 'package:sungoods/providers/product_provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/services/chat_service.dart'; // New Import
import 'package:sungoods/providers/chat_provider.dart'; // New Import
import 'package:sungoods/services/user_service.dart'; // New Import
import 'package:sungoods/providers/user_provider.dart'; // New Import
import 'package:sungoods/services/admin_user_service.dart'; // New Import
import 'package:sungoods/providers/admin_user_provider.dart'; // New Import

import 'package:sungoods/screens/order_confirmation_screen.dart';
import 'package:sungoods/screens/order_history_screen.dart';

import 'package:sungoods/screens/shipping_address_screen.dart';
import 'package:sungoods/screens/login_screen.dart';
import 'package:sungoods/screens/registration_screen.dart';
import 'package:sungoods/screens/admin_panel_screen.dart';
import 'package:sungoods/screens/seller_panel_screen.dart';
import 'package:sungoods/screens/rider_panel_screen.dart';
import 'package:sungoods/screens/buyer_panel_screen.dart'; // New Import
import 'package:sungoods/screens/forgot_password_screen.dart'; // Add missing import
import 'package:sungoods/screens/main_navigation_screen.dart';

import 'package:sungoods/providers/category_provider.dart';
import 'package:sungoods/screens/all_categories_screen.dart';
import 'package:sungoods/screens/category_products_screen.dart';
import 'package:sungoods/providers/wishlist_provider.dart';
import 'package:sungoods/screens/wishlist_screen.dart';
import 'package:sungoods/screens/cost_calculator_screen.dart';
import 'package:sungoods/screens/order_tracking_screen.dart';
import 'package:sungoods/services/rider_dashboard_service.dart';
import 'package:sungoods/providers/rider_dashboard_provider.dart';
import 'package:sungoods/services/seller_dashboard_service.dart';
import 'package:sungoods/providers/seller_dashboard_provider.dart';
import 'package:sungoods/services/cart_service.dart';
import 'package:sungoods/services/order_service.dart';
import 'package:sungoods/services/seller_product_service.dart';
import 'package:sungoods/providers/seller_product_provider.dart';
import 'package:sungoods/providers/notification_provider.dart';
import 'package:sungoods/screens/notification_screen.dart';
import 'package:sungoods/screens/featured_products_screen.dart'; // Add this import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (context, auth, notificationProvider) {
            notificationProvider!.updateToken(auth.token);
            return notificationProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(
            ChatService(''),
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, chat) {
            debugPrint('ChatProvider update with token: ${auth.token}');
            return ChatProvider(ChatService(auth.token ?? ''), auth);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            UserService(''),
          ), // Initial UserService with empty token
          update: (context, auth, userProvider) {
            debugPrint('UserProvider update with token: ${auth.token}');
            return UserProvider(UserService(auth.token ?? ''));
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminUserProvider>(
          create: (context) => AdminUserProvider(
            AdminUserService(''),
          ), // Initial AdminUserService with empty token
          update: (context, auth, adminUserProvider) {
            debugPrint('AdminUserProvider update with token: ${auth.token}');
            return AdminUserProvider(AdminUserService(auth.token ?? ''));
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RiderDashboardProvider>(
          create: (context) =>
              RiderDashboardProvider(RiderDashboardService(null)),
          update: (context, auth, riderDashboardProvider) {
            riderDashboardProvider!.updateService(
              RiderDashboardService(auth.token),
            );
            return riderDashboardProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SellerDashboardProvider>(
          create: (context) =>
              SellerDashboardProvider(SellerDashboardService(null)),
          update: (context, auth, sellerDashboardProvider) {
            sellerDashboardProvider!.updateService(
              SellerDashboardService(auth.token),
            );
            return sellerDashboardProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SellerProductProvider>(
          create: (context) =>
              SellerProductProvider(SellerProductService(null)),
          update: (context, auth, sellerProductProvider) {
            sellerProductProvider!.updateService(
              SellerProductService(auth.token),
            );
            return sellerProductProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (context) => CartProvider(CartService(null)),
          update: (context, auth, cartProvider) {
            debugPrint('CartProvider update with token: ${auth.token}');
            cartProvider!.updateService(
              CartService(auth.token, cartProvider.guestSessionId),
            );
            return cartProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) => OrderProvider(OrderService(null)),
          update: (context, auth, orderProvider) {
            // Get guest session ID from CartProvider
            final cartProvider = Provider.of<CartProvider>(
              context,
              listen: false,
            );
            return OrderProvider(
              OrderService(auth.token, cartProvider.guestSessionId),
            );
          },
        ),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(
          create: (context) => WishlistProvider(),
        ), // Add WishlistProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp(
          title: 'Sungoods', // Changed title
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: appColorsPrimary),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    appColorsPrimary, // Use primary color for ElevatedButtons
                foregroundColor: Colors.white, // Text color for ElevatedButtons
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ), // Consistent border radius
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: appColorsPrimary, // Text color for TextButtons
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    appColorsPrimary, // Text color for OutlinedButtons
                side: const BorderSide(color: appColorsPrimary), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ), // Consistent border radius
                ),
              ),
            ),
          ),
          initialRoute: MainNavigationScreen.routeName,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case MainNavigationScreen.routeName:
                return MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                );
              case '/category-products':
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(
                    categorySlug: args['slug']!,
                    categoryName: args['name']!,
                  ),
                );
              case '/product-detail':
                final product = settings.arguments as Product;
                return MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                );
              case '/cart':
                return MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                );
              case '/order-confirmation':
                return MaterialPageRoute(
                  builder: (context) => const OrderConfirmationScreen(),
                );
              case '/shipping-address':
                return MaterialPageRoute(
                  builder: (context) => const ShippingAddressScreen(),
                );
              case '/orders':
                return MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                );
              case '/account':
                return MaterialPageRoute(
                  builder: (context) => const AccountScreenWrapper(),
                );
              case '/admin-panel':
                return MaterialPageRoute(
                  builder: (context) => const AdminPanelScreen(),
                );
              case '/seller-panel':
                return MaterialPageRoute(
                  builder: (context) => const SellerPanelScreen(),
                );
              case '/rider-panel':
                return MaterialPageRoute(
                  builder: (context) => const RiderPanelScreen(),
                );
              case '/buyer-panel': // New Buyer Panel route
                return MaterialPageRoute(
                  builder: (context) => const BuyerPanelScreen(),
                );
              case '/forgot-password': // New Forgot Password route
                return MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                );
              case '/all-categories':
                return MaterialPageRoute(
                  builder: (context) => const AllCategoriesScreen(),
                );
              case '/wishlist': // Add WishlistScreen route
                return MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                );
              case '/cost-calculator': // Add CostCalculatorScreen route
                return MaterialPageRoute(
                  builder: (context) => const CostCalculatorScreen(),
                );
              case '/order-tracking': // Add OrderTrackingScreen route
                return MaterialPageRoute(
                  builder: (context) => const OrderTrackingScreen(),
                );
              case '/notifications':
                return MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                );
              case '/featured-products':
                return MaterialPageRoute(
                  builder: (context) => const FeaturedProductsScreen(),
                );
              default:
                return MaterialPageRoute(
                  builder: (context) =>
                      Text('Error: Unknown route ${settings.name}'),
                );
            }
          },
        ); // End of MaterialApp
      }, // End of Builder's builder function
    ); // End of Builder widget
  }
}
