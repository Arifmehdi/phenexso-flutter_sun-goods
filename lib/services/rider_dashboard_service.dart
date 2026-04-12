import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/models/rider_dashboard.dart';
import 'package:sungoods/models/order.dart';

class RiderDashboardService {
  final String? _token;

  RiderDashboardService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<RiderDashboard> fetchRiderDashboardData() async {
    if (_token == null) throw Exception('Authentication token is missing.');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/rider/dashboard');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return RiderDashboard.fromJson(responseData);
    } else {
      throw Exception(
        json.decode(response.body)['message'] ??
            'Failed to load dashboard data',
      );
    }
  }

  Future<List<Order>> fetchActiveOrders() async {
    if (_token == null) throw Exception('Authentication token is missing.');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/rider/active-orders');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      return data.map((o) => Order.fromJson(o)).toList();
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Failed to load active orders',
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? note}) async {
    if (_token == null) throw Exception('Authentication token is missing.');

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/rider/orders/$orderId/update-status',
    );
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({
        'status': status,
        if (note != null && note.isNotEmpty) 'order_note': note,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        json.decode(response.body)['message'] ??
            'Failed to update order status',
      );
    }
  }

  // You might want a dedicated endpoint for order history,
  // but for now let's assume we use all orders from dashboard or another endpoint.
  Future<List<Order>> fetchOrderHistory() async {
    if (_token == null) throw Exception('Authentication token is missing.');

    // Assuming we might have a dedicated endpoint for history or we filter dashboard data.
    // Based on the provided drivers.txt, there's no explicit /rider/history-orders endpoint,
    // but typically history is delivered/canceled orders.
    // We can use the dashboard recent_orders or create a new endpoint if it exists.
    // Since it's not in drivers.txt, I'll assume we might need a general orders endpoint if it existed,
    // or we just use dashboard recent_orders for now.
    // Wait, let's check if there's any other endpoint in drivers.txt. No.
    // I'll assume /rider/dashboard gives recent orders which can be history.
    // Alternatively, I'll just return recent orders from dashboard for now.

    final dashboard = await fetchRiderDashboardData();
    return dashboard.recentOrders;
  }
}
