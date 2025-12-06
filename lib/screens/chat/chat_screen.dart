import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/typing_indicator.dart';
import '../../widgets/message_input.dart';
import '../../widgets/avatar_widget.dart';
import '../../utils/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _updateTypingStatus(false);
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    
    if (authService.currentUserId != null) {
      await chatService.markMessagesAsRead(
        widget.chatId,
        authService.currentUserId!,
      );
    }
  }

  Future<void> _updateTypingStatus(bool isTyping) async {
    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    
    if (authService.currentUserId != null) {
      await chatService.updateTypingStatus(
        widget.chatId,
        authService.currentUserId!,
        isTyping,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    final currentUserId = authService.currentUserId;

    if (currentUserId == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();
    _updateTypingStatus(false);

    try {
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: currentUserId,
        receiverId: widget.otherUser.id,
        content: content,
        type: AppConstants.textMessage,
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    final storageService = context.read<StorageService>();
    final currentUserId = authService.currentUserId;

    if (currentUserId == null) return;

    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Upload image
      final imageUrl = await storageService.uploadChatImage(
        widget.chatId,
        File(pickedFile.path),
      );

      // Send message with image
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: currentUserId,
        receiverId: widget.otherUser.id,
        content: 'Photo',
        type: AppConstants.imageMessage,
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _messageController.text += emoji.emoji;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showReactionPicker(MessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'React to message',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['❤️', '😍', '😊', '😂', '😢', '👍'].map((emoji) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final chatService = context.read<ChatService>();
                    await chatService.addReaction(message.id, emoji);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 40)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            AvatarWidget(
              imageUrl: widget.otherUser.avatarUrl,
              name: widget.otherUser.name,
              radius: 20,
              showOnlineIndicator: true,
              isOnline: widget.otherUser.isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  StreamBuilder<UserModel?>(
                    stream: authService.streamUserData(widget.otherUser.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final user = snapshot.data!;
                      return Text(
                        user.isOnline
                            ? 'Online'
                            : user.lastSeen != null
                                ? DateFormatter.formatLastSeen(user.lastSeen!)
                                : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: user.isOnline
                              ? Colors.green
                              : AppTheme.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // Video call feature
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // Voice call feature
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: chatService.streamMessages(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: AppTheme.roseGold.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = snapshot.data!;
                  
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      // Typing indicator
                      if (index == 0) {
                        return StreamBuilder(
                          stream: chatService.streamChat(widget.chatId),
                          builder: (context, chatSnapshot) {
                            if (!chatSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final chat = chatSnapshot.data!;
                            final isOtherTyping = chat.isOtherTyping(
                              authService.currentUserId!,
                            );
                            
                            if (isOtherTyping) {
                              return TypingIndicator(
                                userName: widget.otherUser.name,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      }

                      final message = messages[index - 1];
                      final isSentByMe = message.senderId ==
                          authService.currentUserId;

                      // Date divider
                      bool showDateDivider = false;
                      if (index < messages.length) {
                        final nextMessage = messages[index];
                        showDateDivider = !DateFormatter.isSameDay(
                          message.timestamp,
                          nextMessage.timestamp,
                        );
                      } else {
                        showDateDivider = true;
                      }

                      return Column(
                        children: [
                          if (showDateDivider)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.roseGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormatter.formatDateDivider(
                                    message.timestamp,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ),
                            ),
                          ChatBubble(
                            message: message,
                            isSentByMe: isSentByMe,
                            onReaction: () => _showReactionPicker(message),
                            onImageTap: () {
                              // Show full screen image
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Emoji Picker
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _onEmojiSelected(emoji);
                  },
                  config: Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Message Input
            MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
              onEmojiTap: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                });
              },
              onImageTap: _sendImageMessage,
              onChanged: (text) {
                if (text.trim().isNotEmpty && !_isTyping) {
                  _isTyping = true;
                  _updateTypingStatus(true);
                } else if (text.trim().isEmpty && _isTyping) {
                  _isTyping = false;
                  _updateTypingStatus(false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
