import 'package:sungoods/models/order.dart';
import 'package:sungoods/models/product.dart';

class RiderStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int totalProducts;

  RiderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.totalProducts,
  });

  factory RiderStats.fromJson(Map<String, dynamic> json) {
    return RiderStats(
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      confirmedOrders: json['confirmed_orders'] ?? 0,
      shippedOrders: json['shipped_orders'] ?? 0,
      deliveredOrders: json['delivered_orders'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
    );
  }
}

class RiderProfile {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String? licenseNo;
  final String? address;
  final String? image;
  final String status;

  RiderProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.licenseNo,
    this.address,
    this.image,
    required this.status,
  });

  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    return RiderProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      licenseNo: json['license_no'],
      address: json['address'],
      image: json['image'],
      status: json['status'] ?? 'Pending',
    );
  }
}

class RiderDashboard {
  final RiderProfile rider;
  final RiderStats stats;
  final dynamic assignedVehicle; // You might want a proper Vehicle model later
  final List<Order> recentOrders;
  final List<Product> assignedProducts;

  RiderDashboard({
    required this.rider,
    required this.stats,
    this.assignedVehicle,
    required this.recentOrders,
    required this.assignedProducts,
  });

  factory RiderDashboard.fromJson(Map<String, dynamic> json) {
    var data = json['data'] ?? json;
    
    var recentOrdersList = (data['recent_orders'] as List? ?? [])
        .map((o) => Order.fromJson(o))
        .toList();
        
    var assignedProductsList = (data['assigned_products'] as List? ?? [])
        .map((p) => Product.fromJson(p))
        .toList();

    return RiderDashboard(
      rider: RiderProfile.fromJson(data['rider'] ?? {}),
      stats: RiderStats.fromJson(data['stats'] ?? {}),
      assignedVehicle: data['assigned_vehicle'],
      recentOrders: recentOrdersList,
      assignedProducts: assignedProductsList,
    );
  }
}
