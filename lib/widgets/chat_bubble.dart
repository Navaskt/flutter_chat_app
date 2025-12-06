import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message_model.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../utils/date_formatter.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;
  final VoidCallback? onReaction;
  final VoidCallback? onImageTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.onReaction,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: onReaction,
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSentByMe
                          ? const LinearGradient(
                              colors: AppTheme.sentMessageGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: AppTheme.receivedMessageGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(
                            AppConstants.messageBorderRadius),
                        topRight: const Radius.circular(
                            AppConstants.messageBorderRadius),
                        bottomLeft: Radius.circular(
                          isSentByMe ? AppConstants.messageBorderRadius : 4,
                        ),
                        bottomRight: Radius.circular(
                          isSentByMe ? 4 : AppConstants.messageBorderRadius,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(
                            AppConstants.messageBorderRadius),
                        topRight: const Radius.circular(
                            AppConstants.messageBorderRadius),
                        bottomLeft: Radius.circular(
                          isSentByMe ? AppConstants.messageBorderRadius : 4,
                        ),
                        bottomRight: Radius.circular(
                          isSentByMe ? 4 : AppConstants.messageBorderRadius,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image message
                                if (message.type == AppConstants.imageMessage &&
                                    message.imageUrl != null)
                                  GestureDetector(
                                    onTap: onImageTap,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: message.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: 200,
                                        placeholder: (context, url) =>
                                            Container(
                                          width: 200,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                
                                // Text content
                                if (message.content.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: message.type ==
                                              AppConstants.imageMessage
                                          ? 8
                                          : 0,
                                    ),
                                    child: Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 4),
                                
                                // Time and status
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormatter.formatMessageTime(
                                          message.timestamp),
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white.withOpacity(0.8)
                                            : AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (isSentByMe) ...[
                                      const SizedBox(width: 4),
                                      _buildStatusIcon(),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Reaction badge
                          if (message.hasReaction && message.reaction != null)
                            Positioned(
                              bottom: -8,
                              right: isSentByMe ? null : 8,
                              left: isSentByMe ? 8 : null,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSentByMe
                                        ? AppTheme.roseGold
                                        : AppTheme.lightLavender,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  message.reaction!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (message.status == AppConstants.messageRead) {
      return const Icon(
        Icons.done_all,
        size: 16,
        color: AppTheme.accentPurple,
      );
    } else if (message.status == AppConstants.messageDelivered) {
      return Icon(
        Icons.done_all,
        size: 16,
        color: Colors.white.withOpacity(0.8),
      );
    } else {
      return Icon(
        Icons.done,
        size: 16,
        color: Colors.white.withOpacity(0.8),
      );
    }
  }
}
