class ApiConstants {
  static const String baseUrl = 'https://hublibd.com';
  static const String loginEndpoint = '$baseUrl/api/login';
  static const String registerEndpoint = '$baseUrl/api/register';
  static const String logoutEndpoint = '$baseUrl/api/logout'; // New logout endpoint
  static const String chatBaseUrl = '$baseUrl/api/chat'; // New chat base URL
  static const String imageUploadsBaseUrl = '$baseUrl/uploads/'; // Assuming images are here
  static const String forgotPasswordEndpoint = '$baseUrl/api/forgot-password'; // New: Forgot Password Endpoint
  static const String cartEndpoint = '$baseUrl/api/cart'; // New: Cart Endpoint
  static const String ordersEndpoint = '$baseUrl/api/orders'; // New: Orders Endpoint
  static const String allOrdersEndpoint = '$baseUrl/api/order-list'; // New: All Orders Endpoint (Admin)
  static const String sellerOrdersEndpoint = '$baseUrl/api/seller/orders'; // New: Seller Orders Endpoint
  static const String productsEndpoint = '$baseUrl/api/products'; // New: Products Endpoint
  static const String sellerProductsEndpoint = '$baseUrl/api/seller/products'; // New: Seller Products Endpoint
  static const String notificationsEndpoint = '$baseUrl/api/notifications'; // New: Notifications Endpoint
}
