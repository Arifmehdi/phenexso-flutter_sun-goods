class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final String? ipAddress;
  final String? type;
  final bool allShow;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    this.ipAddress,
    this.type,
    required this.allShow,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      ipAddress: json['ip_address']?.toString(),
      type: json['type']?.toString(),
      allShow: (json['all_show'] == 1 || json['all_show'] == true || json['all_show'] == '1'),
      isRead: (json['is_read'] == 1 || json['is_read'] == true || json['is_read'] == '1'),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'ip_address': ipAddress,
      'type': type,
      'all_show': allShow ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
