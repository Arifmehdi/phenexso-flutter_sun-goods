// lib/providers/chat_provider.dart
import 'dart:async'; // Import for Timer
// Import for json.decode
import 'dart:io'; // Import for File

import 'package:flutter/material.dart';
import 'package:sungoods/models/chat/conversation.dart';
import 'package:sungoods/models/chat/message.dart';
import 'package:sungoods/models/chat/user.dart';
import 'package:sungoods/services/chat_service.dart';
import 'package:sungoods/providers/auth_provider.dart'; // Import AuthProvider

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final AuthProvider _authProvider; // Add AuthProvider
  Timer? _pollingTimer; // For message polling

  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  Conversation? _currentConversation;
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  String? _errorMessage;

  ChatProvider(this._chatService, this._authProvider); // Update constructor

  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get errorMessage => _errorMessage;

  void _setLoadingConversations(bool value) {
    _isLoadingConversations = value;
    notifyListeners();
  }

  void _setLoadingMessages(bool value) {
    _isLoadingMessages = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchConversations() async {
    _setLoadingConversations(true);
    _setErrorMessage(null);
    try {
      _conversations = await _chatService.getConversations();
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoadingConversations(false);
    }
  }

  void setCurrentConversation(Conversation conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void clearMessages() {
    _currentMessages = [];
    _currentConversation = null;
    _pollingTimer?.cancel();
    notifyListeners();
  }

  // fetchMessages now fetches messages via HTTP and sets up polling
  Future<void> fetchMessages(int conversationId) async {
    _currentMessages = []; // Clear existing messages immediately
    _setLoadingMessages(true);
    _setErrorMessage(null);
    _pollingTimer?.cancel(); // Cancel any existing timer

    try {
      _currentMessages = await _chatService.getMessages(conversationId);
      // Ensure messages are ordered from oldest to newest for display
      _currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Start polling for new messages
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (_currentConversation?.id != conversationId) {
          // If conversation changed or no current conversation, stop polling
          timer.cancel();
          return;
        }

        try {
          final newMessages = await _chatService.getMessages(conversationId);
          if (newMessages.length > _currentMessages.length) {
            // Only update if new messages have arrived
            _currentMessages = newMessages
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            notifyListeners();
          }
        } catch (e) {
          print('Error during message polling: $e');
          // Optionally set an error message, but don't stop polling unless critical
        }
      });
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoadingMessages(false);
    }
  }

  // Modified sendMessage to handle files
  Future<void> sendMessage(
    int conversationId, {
    String? messageContent,
    required String messageType,
    File? file,
  }) async {
    _setErrorMessage(null);
    try {
      // Ensure either messageContent or file is provided
      if (messageContent == null && file == null) {
        throw Exception("Cannot send an empty message or without a file.");
      }

      final newMessage = await _chatService.sendMessage(
        conversationId,
        message: messageContent,
        messageType: messageType,
        file: file,
      );
      _currentMessages.add(newMessage); // Add new message to the end
      // Update latest message in conversations list if this is the current conversation
      final index = _conversations.indexWhere(
        (conv) => conv.id == conversationId,
      );
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          latestMessage: newMessage,
          lastMessageAt: newMessage.createdAt,
        );
      }
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      notifyListeners();
    }
  }

  // Function to create a new conversation
  Future<Conversation?> createConversation({
    String? title,
    required String type,
    required List<int> participantIds,
  }) async {
    _setErrorMessage(null);
    try {
      final newConversation = await _chatService.createConversation(
        title: title,
        type: type,
        participantIds: participantIds,
      );
      _conversations.insert(
        0,
        newConversation,
      ); // Add new conversation to the top
      notifyListeners();
      return newConversation;
    } catch (e) {
      _setErrorMessage(e.toString());
      return null;
    }
  }

  // Function to get or create a private conversation
  Future<Conversation?> getOrCreatePrivateConversation(int userId) async {
    _setErrorMessage(null);
    try {
      final conversation = await _chatService.getOrCreatePrivateConversation(
        userId,
      );
      // Check if conversation already exists in the list, if not, add it
      if (!_conversations.any((conv) => conv.id == conversation.id)) {
        _conversations.insert(0, conversation);
      }
      notifyListeners();
      return conversation;
    } catch (e) {
      _setErrorMessage(e.toString());
      return null;
    }
  }

  // Function to search users
  Future<List<User>> searchUsers(String query) async {
    _setErrorMessage(null);
    try {
      return await _chatService.searchUsers(query);
    } catch (e) {
      _setErrorMessage(e.toString());
      return [];
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancel timer when provider is disposed
    super.dispose();
  }
}
