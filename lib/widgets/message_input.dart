import 'package:flutter/material.dart';
import '../config/theme.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;
  final VoidCallback onImageTap;
  final Function(String) onChanged;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onEmojiTap,
    required this.onImageTap,
    required this.onChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Emoji button
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              color: AppTheme.roseGold,
              onPressed: widget.onEmojiTap,
            ),
            
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.image_outlined),
                      color: AppTheme.roseGold,
                      onPressed: widget.onImageTap,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            Container(
              decoration: BoxDecoration(
                gradient: _hasText
                    ? const LinearGradient(
                        colors: AppTheme.sentMessageGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _hasText ? null : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: AppTheme.roseGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: _hasText ? widget.onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
