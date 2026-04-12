class Category {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl; // Nullable as image might not always be present

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '').toString(),
      name:
          json['name'] as String? ??
          'Unknown Category', // Use 'name_en' as per table.txt
      slug:
          json['slug'] as String? ??
          (json['name_en'] as String? ?? 'unknown').toLowerCase().replaceAll(
            ' ',
            '-',
          ), // Prefer 'slug', fallback to derive from 'name_en'
      imageUrl:
          (json['image'] != null &&
              json['image'].isNotEmpty) // Use 'image' as per table.txt
          ? 'https://hublibd.com/uslive/pnism/${json['image']}' // Assuming similar image path prefix as products
          : null,
    );
  }
}
