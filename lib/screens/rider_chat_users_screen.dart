import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sungoods/providers/chat_provider.dart';
import 'package:sungoods/providers/user_provider.dart';
import 'package:sungoods/models/chat/user.dart' as chat_user;
import 'package:sungoods/screens/conversation_screen.dart';
import 'package:sungoods/screens/search_users_screen.dart';
import 'package:sungoods/utils/api_constants.dart';

class RiderChatUsersScreen extends StatefulWidget {
  const RiderChatUsersScreen({super.key});

  @override
  State<RiderChatUsersScreen> createState() => _RiderChatUsersScreenState();
}

class _RiderChatUsersScreenState extends State<RiderChatUsersScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoading && userProvider.users.isEmpty) {
      userProvider.fetchAllUsers();
    }
  }

  Future<void> _startChatWithUser(chat_user.User user) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final conversation = await chatProvider.getOrCreatePrivateConversation(user.id);
      if (conversation != null && mounted) {
        chatProvider.setCurrentConversation(conversation);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              conversationId: conversation.id,
              conversationTitle: user.name,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userProvider.errorMessage != null) {
            return Center(child: Text('Error: ${userProvider.errorMessage}'));
          }
          if (userProvider.users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                        ? NetworkImage('${ApiConstants.imageUploadsBaseUrl}${user.profilePhoto!}') as ImageProvider
                        : null,
                    child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                        ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email ?? 'No email'),
                  onTap: () => _startChatWithUser(user),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SearchUsersScreen()),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}