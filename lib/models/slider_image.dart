class SliderImage {
  final int id;
  final String imageUrl;
  final String? title;
  final String? link;
  final int status; // 1 for visible, 0 for hidden

  SliderImage({
    required this.id,
    required this.imageUrl,
    this.title,
    this.link,
    this.status = 1,
  });

  factory SliderImage.fromJson(Map<String, dynamic> json) {
    return SliderImage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      title: json['title'],
      link: json['link'],
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'link': link,
      'status': status,
    };
  }

  SliderImage copyWith({
    int? id,
    String? imageUrl,
    String? title,
    String? link,
    int? status,
  }) {
    return SliderImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      link: link ?? this.link,
      status: status ?? this.status,
    );
  }
}
