// lib/widgets/chat/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/models/chat/message.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:cached_network_image/cached_network_image.dart'; // Import for cached images

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    final isMe = message.senderId == currentUserId;

    // Check if the message has been read by anyone other than the sender
    bool isRead = false;
    if (message.reads != null && currentUserId != null) {
      isRead = message.reads!.any((read) => read.userId != currentUserId);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.sender != null) // Show sender name for others' messages
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.sender!.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white70 : Colors.black87,
                    fontSize: 12.0,
                  ),
                ),
              ),
            // Message Content
            if (message.messageType == 'image' && message.fileUrl != null)
              GestureDetector(
                onTap: () {
                  // TODO: Implement image viewer
                  print('Image tapped: ${message.fileUrl}');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: message.fileUrl!,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: 200, // Constrain image width
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (message.message.isNotEmpty)
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              )
            else
              const SizedBox.shrink(), // For empty text messages or unsupported types

            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14.0,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String datePart;
    if (messageDate == today) {
      datePart = ''; // No date for today, just time
    } else if (messageDate == yesterday) {
      datePart = 'Yesterday, ';
    } else if (now.difference(messageDate).inDays < 7) {
      datePart = '${DateFormat('EEEE').format(dateTime)}, '; // Day of the week
    } else {
      datePart = '${DateFormat('MMM d, y').format(dateTime)}, '; // Full date
    }

    return '$datePart${DateFormat('hh:mm a').format(dateTime)}';
  }
}
