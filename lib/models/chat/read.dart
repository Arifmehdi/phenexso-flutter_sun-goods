// lib/models/chat/read.dart
// Helper function to safely parse int, returns 0 if null or invalid
int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty) return 0;
    try {
      return int.parse(value);
    } catch (_) {
      return 0;
    }
  }
  return 0;
}

class Read {
  final int id;
  final int messageId;
  final int userId;
  final DateTime readAt;

  Read({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.readAt,
  });

  factory Read.fromJson(Map<String, dynamic> json) {
    return Read(
      id: _safeParseInt(json['id']),
      messageId: _safeParseInt(json['message_id']),
      userId: _safeParseInt(json['user_id']),
      readAt: DateTime.parse(json['read_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'read_at': readAt.toIso8601String(),
    };
  }
}
