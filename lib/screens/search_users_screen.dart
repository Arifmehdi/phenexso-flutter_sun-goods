// lib/screens/search_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/chat_provider.dart';
import 'package:sungoods/models/chat/user.dart';
import 'package:sungoods/screens/conversation_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _searchResults = await chatProvider.searchUsers(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _startPrivateChat(User user) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final conversation = await chatProvider.getOrCreatePrivateConversation(user.id);
      if (conversation != null && mounted) {
        // Navigate to the conversation screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              conversationId: conversation.id,
              conversationTitle: user.name, // Title with the other user's name
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Text('Error: $_errorMessage')))
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(child: Center(child: Text('No users found.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0] : '?'), // Display first letter of name, or '?' if empty
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email ?? ''),
                    onTap: () => _startPrivateChat(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
