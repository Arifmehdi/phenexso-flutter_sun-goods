// lib/services/chat_service.dart
import 'dart:convert';
import 'dart:io'; // Import for File
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/models/chat/conversation.dart';
import 'package:sungoods/models/chat/message.dart';
import 'package:sungoods/models/chat/user.dart';

class ChatService {
  final String _authToken;

  ChatService(this._authToken);

  Map<String, String> _getHeaders({bool isMultipart = false}) {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // Fetch user's conversations
  Future<List<Conversation>> getConversations() async {
    final uri = Uri.parse('${ApiConstants.chatBaseUrl}/conversations');
    // print('DEBUG: Fetching conversations from: $uri');
    // print('DEBUG: Headers: ${_getHeaders()}');

    final response = await http.get(uri, headers: _getHeaders());

    // print('DEBUG: Response status code for getConversations: ${response.statusCode}');
    // print('DEBUG: Response body for getConversations: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['conversations']['data'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load conversations');
      }
    } else {
      throw Exception(
        'Failed to load conversations: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  // Create new conversation
  Future<Conversation> createConversation({
    String? title,
    required String type,
    required List<int> participantIds,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.chatBaseUrl}/conversations'),
      headers: _getHeaders(),
      body: json.encode({
        'title': title,
        'type': type,
        'participants': participantIds,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return Conversation.fromJson(data['conversation']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create conversation');
      }
    } else {
      throw Exception('Failed to create conversation: ${response.statusCode}');
    }
  }

  // Get messages in a conversation
  Future<List<Message>> getMessages(int conversationId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.chatBaseUrl}/conversations/$conversationId/messages',
      ),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['messages']['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load messages');
      }
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Send message
  Future<Message> sendMessage(
    int conversationId, {
    String? message,
    required String messageType,
    File? file,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.chatBaseUrl}/conversations/$conversationId/messages',
    );
    print('DEBUG: Sending message to URI: $uri');
    print('DEBUG: Auth Headers: ${_getHeaders()}');
    print('DEBUG: Message Type: $messageType');

    if (file != null) {
      // Handle file upload
      print('DEBUG: Sending file: ${file.path}');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(
        _getHeaders(isMultipart: true),
      ); // Add auth token to multipart
      request.fields['message_type'] = messageType;
      if (message != null) {
        request.fields['message'] = message;
      }
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: File message response status: ${response.statusCode}');
      print('DEBUG: File message response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Message.fromJson(data['message']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send file message');
        }
      } else {
        throw Exception(
          'Failed to send file message: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } else {
      // Handle text message
      final body = json.encode({
        'message': message,
        'message_type': messageType,
      });
      print('DEBUG: Text message body: $body');
      final response = await http.post(uri, headers: _getHeaders(), body: body);

      print('DEBUG: Text message response status: ${response.statusCode}');
      print('DEBUG: Text message response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Message.fromJson(data['message']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send text message');
        }
      } else {
        throw Exception(
          'Failed to send text message: ${response.statusCode}. Body: ${response.body}',
        );
      }
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(int messageId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.chatBaseUrl}/messages/$messageId/read'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read: ${response.statusCode}');
    }
  }

  // Search users for chat
  Future<List<User>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.chatBaseUrl}/users/search?search=$query'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to search users');
      }
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }

  // Get or create private conversation with a user
  Future<Conversation> getOrCreatePrivateConversation(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.chatBaseUrl}/users/$userId/conversation'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return Conversation.fromJson(data['conversation']);
      } else {
        throw Exception(
          data['message'] ?? 'Failed to get or create private conversation',
        );
      }
    } else {
      throw Exception(
        'Failed to get or create private conversation: ${response.statusCode}',
      );
    }
  }
}
