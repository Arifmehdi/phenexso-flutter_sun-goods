// lib/models/chat/message.dart
import 'package:sungoods/models/chat/user.dart';
import 'package:sungoods/models/chat/read.dart';

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

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final String messageType;
  final bool isRead;
  final String? fileUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final User? sender; // Simplified for chat context
  final List<Read>? reads;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.isRead,
    this.fileUrl,
    this.thumbnailUrl,
    required this.createdAt,
    this.sender,
    this.reads,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: _safeParseInt(json['id']),
      conversationId: _safeParseInt(json['conversation_id']),
      senderId: _safeParseInt(json['sender_id']),
      message: json['message'],
      messageType: json['message_type'],
      isRead: json['is_read'] == 1, // Assuming 0 or 1 from API
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      reads: json['reads'] != null
          ? (json['reads'] as List).map((i) => Read.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'is_read': isRead ? 1 : 0,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
      'reads': reads?.map((e) => e.toJson()).toList(),
    };
  }
}
