// lib/models/chat/conversation.dart
import 'package:sungoods/models/chat/message.dart';
import 'package:sungoods/models/chat/participant.dart';

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

class Conversation {
  final int id;
  final String? title;
  final String type; // 'private', 'group'
  final int createdBy;
  final DateTime lastMessageAt;
  final Message? latestMessage;
  final List<Participant> participants;
  final int unreadCount;

  Conversation({
    required this.id,
    this.title,
    required this.type,
    required this.createdBy,
    required this.lastMessageAt,
    this.latestMessage,
    required this.participants,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: _safeParseInt(json['id']),
      title: json['title'],
      type: json['type'],
      createdBy: _safeParseInt(json['created_by']),
      lastMessageAt: DateTime.parse(json['last_message_at']),
      latestMessage: json['latest_message'] != null
          ? Message.fromJson(json['latest_message'])
          : null,
      participants: (json['participants'] as List)
          .map((i) => Participant.fromJson(i))
          .toList(),
      unreadCount: _safeParseInt(json['unread_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'created_by': createdBy,
      'last_message_at': lastMessageAt.toIso8601String(),
      'latest_message': latestMessage?.toJson(),
      'participants': participants.map((e) => e.toJson()).toList(),
      'unread_count': unreadCount,
    };
  }

  Conversation copyWith({
    int? id,
    String? title,
    String? type,
    int? createdBy,
    DateTime? lastMessageAt,
    Message? latestMessage,
    List<Participant>? participants,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      latestMessage: latestMessage ?? this.latestMessage,
      participants: participants ?? this.participants,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
