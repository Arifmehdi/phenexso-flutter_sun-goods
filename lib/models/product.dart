class Product {
  final String id;
  final String name;
  final double price;
  final double purchasePrice;
  final int stock;
  final List<String> imageUrls;
  final String category;
  final String? categoryId;
  final double rating;
  final String description;
  final String? unit;
  final int active;
  final int featured;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.purchasePrice,
    required this.stock,
    required this.imageUrls,
    required this.category,
    this.categoryId,
    required this.rating,
    required this.description,
    this.unit,
    required this.active,
    required this.featured,
  });

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String categoryName = 'Uncategorized';
    if (json['categories'] != null && (json['categories'] as List).isNotEmpty) {
      categoryName = json['categories'][0]['name'] ?? 'Uncategorized';
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name_en'] as String? ?? 'Unknown Product',
      price: _safeDouble(json['price']),
      purchasePrice: _safeDouble(json['purchase_price']),
      stock: _safeInt(json['stock']),
      imageUrls: [
        (json['featured_image'] != null
            ? 'https://hublibd.com/uslive/pnism/${json['featured_image']}'
            : 'assets/images/placeholder.png'),
      ],
      category: categoryName,
      categoryId: (json['category_id'] ?? '').toString(),
      rating: _safeDouble(json['average_rating']),
      description:
          json['description_en'] as String? ?? 'No description available.',
      unit: json['unit'] as String?,
      active: _safeInt(json['active']),
      featured: _safeInt(json['feature']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': name,
      'price': purchasePrice,
      'stock': stock,
      'featured_image': imageUrls.isNotEmpty
          ? imageUrls[0].replaceAll('https://hublibd.com/uploads/product/', '')
          : null,
      'category': category,
      'average_rating': rating,
      'description_en': description,
      'active': active,
      'feature': featured,
    };
  }
}
