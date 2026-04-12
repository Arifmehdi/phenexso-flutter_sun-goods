class SellerDashboard {
  final double totalSalesToday;
  final double totalSalesWeek;
  final double totalSalesMonth;
  final int totalOrdersPending;
  final int totalOrdersShipped;
  final int totalOrdersDelivered;
  final int totalProducts;
  final int newMessages;
  final int newReviews;

  SellerDashboard({
    required this.totalSalesToday,
    required this.totalSalesWeek,
    required this.totalSalesMonth,
    required this.totalOrdersPending,
    required this.totalOrdersShipped,
    required this.totalOrdersDelivered,
    required this.totalProducts,
    required this.newMessages,
    required this.newReviews,
  });

  factory SellerDashboard.fromJson(Map<String, dynamic> json) {
    return SellerDashboard(
      totalSalesToday: (json['total_sales_today'] ?? 0.0).toDouble(),
      totalSalesWeek: (json['total_sales_week'] ?? 0.0).toDouble(),
      totalSalesMonth: (json['total_sales_month'] ?? 0.0).toDouble(),
      totalOrdersPending: json['total_orders_pending'] ?? 0,
      totalOrdersShipped: json['total_orders_shipped'] ?? 0,
      totalOrdersDelivered: json['total_orders_delivered'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      newMessages: json['new_messages'] ?? 0,
      newReviews: json['new_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales_today': totalSalesToday,
      'total_sales_week': totalSalesWeek,
      'total_sales_month': totalSalesMonth,
      'total_orders_pending': totalOrdersPending,
      'total_orders_shipped': totalOrdersShipped,
      'total_orders_delivered': totalOrdersDelivered,
      'total_products': totalProducts,
      'new_messages': newMessages,
      'new_reviews': newReviews,
    };
  }
}
