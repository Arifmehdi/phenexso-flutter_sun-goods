import 'package:flutter/foundation.dart';

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double productPrice;
  final double totalCost;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.totalCost,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? json['name'] ?? 'Unknown Product',
      quantity: (json['quantity'] is String)
          ? int.tryParse(json['quantity']) ?? 0
          : (json['quantity'] ?? 0),
      productPrice: (json['product_price'] is String)
          ? double.tryParse(json['product_price']) ?? 0.0
          : (json['product_price'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] is String)
          ? double.tryParse(json['total_cost']) ?? 0.0
          : (json['total_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Order {
  final String id;
  final double subtotal;
  final double deliveryCost;
  final double grandTotal;
  final List<OrderItem> items;
  final DateTime orderDate;
  final String name;
  final String mobile;
  final String? email;
  final String addressTitle;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? orderNote;
  
  // Timestamps
  final DateTime? pendingAt;
  final DateTime? confirmedAt;
  final DateTime? readyToShipAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? canceledAt;

  Order({
    required this.id,
    required this.subtotal,
    required this.deliveryCost,
    required this.grandTotal,
    required this.items,
    required this.orderDate,
    required this.name,
    required this.mobile,
    this.email,
    required this.addressTitle,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.orderNote,
    this.pendingAt,
    this.confirmedAt,
    this.readyToShipAt,
    this.shippedAt,
    this.deliveredAt,
    this.canceledAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle potential list key differences
    var itemsList =
        (json['order_items'] ?? json['orderItems'] ?? json['items']) as List? ??
        [];
    List<OrderItem> fetchedItems = itemsList
        .map((i) => OrderItem.fromJson(i))
        .toList();

    // Safe date parsing helper
    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (e) {
        return null;
      }
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ).toLocal();
    } catch (e) {
      debugPrint('Order mapping: Invalid date format ${json['created_at']}');
      parsedDate = DateTime.now();
    }

    return Order(
      id: (json['id'] ?? '').toString(),
      subtotal: (json['subtotal'] is String)
          ? double.tryParse(json['subtotal']) ?? 0.0
          : (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryCost: (json['delivery_cost'] is String)
          ? double.tryParse(json['delivery_cost']) ?? 0.0
          : (json['delivery_cost'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] is String)
          ? double.tryParse(json['grand_total']) ?? 0.0
          : (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      items: fetchedItems,
      orderDate: parsedDate,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      addressTitle: json['address_title'] ?? json['address'] ?? '',
      paymentMethod: json['payment_method'] ?? 'N/A',
      paymentStatus: json['payment_status'] ?? 'pending',
      orderStatus: json['order_status'] ?? 'pending',
      orderNote: json['order_note'],
      pendingAt: _parseDateTime(json['pending_at']),
      confirmedAt: _parseDateTime(json['confirmed_at']),
      readyToShipAt: _parseDateTime(json['ready_to_ship_at']),
      shippedAt: _parseDateTime(json['shiped_at']), // Matching 'shiped_at' from backend
      deliveredAt: _parseDateTime(json['delivered_at']),
      canceledAt: _parseDateTime(json['canceled_at']),
    );
  }
}
