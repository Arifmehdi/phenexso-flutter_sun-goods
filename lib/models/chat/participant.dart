// lib/models/chat/participant.dart
import 'package:sungoods/models/chat/user.dart';

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

class Participant {
  final int id;
  final int conversationId;
  final int userId;
  final bool isAdmin;
  final User? user; // Simplified for chat context

  Participant({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.isAdmin,
    this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: _safeParseInt(json['id']),
      conversationId: _safeParseInt(json['conversation_id']),
      userId: _safeParseInt(json['user_id']),
      isAdmin: json['is_admin'] == 1, // Assuming 0 or 1 from API
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'is_admin': isAdmin ? 1 : 0,
      'user': user?.toJson(),
    };
  }
}
