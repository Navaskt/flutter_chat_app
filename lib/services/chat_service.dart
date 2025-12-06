import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../config/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get existing chat between two users
  Future<String> createOrGetChat(String userId1, String userId2) async {
    try {
      // Check if chat already exists
      final existingChat = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in existingChat.docs) {
        final chat = ChatModel.fromDocument(doc);
        if (chat.participants.contains(userId2)) {
          return doc.id;
        }
      }

      // Create new chat
      final chatDoc = await _firestore
          .collection(AppConstants.chatsCollection)
          .add({
        'participants': [userId1, userId2],
        'lastMessage': null,
        'lastMessageTime': null,
        'lastMessageSenderId': null,
        'lastMessageType': null,
        'isTyping': {userId1: false, userId2: false},
        'unreadCount': {userId1: 0, userId2: 0},
      });

      return chatDoc.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Send text message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String type = AppConstants.textMessage,
    String? imageUrl,
  }) async {
    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        status: AppConstants.messageSent,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      // Add message to messages collection
      await _firestore
          .collection(AppConstants.messagesCollection)
          .add(message.toMap());

      // Update chat with last message info
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({
        'lastMessage': content,
        'lastMessageType': type,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSenderId': senderId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      // Clear typing status
      await updateTypingStatus(chatId, senderId, false);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Update message status (delivered, read)
  Future<void> updateMessageStatus(
    String messageId,
    String status,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String chatId,
    String currentUserId,
  ) async {
    try {
      final messagesSnapshot = await _firestore
          .collection(AppConstants.messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isNotEqualTo: AppConstants.messageRead)
          .get();

      final batch = _firestore.batch();

      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'status': AppConstants.messageRead});
      }

      // Reset unread count
      batch.update(
        _firestore.collection(AppConstants.chatsCollection).doc(chatId),
        {'unreadCount.$currentUserId': 0},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Update typing status
  Future<void> updateTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({
        'isTyping.$userId': isTyping,
        if (isTyping)
          'typingTimestamp.$userId': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail - typing status is not critical
    }
  }

  // Add reaction to message
  Future<void> addReaction(
    String messageId,
    String reaction,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .update({
        'hasReaction': true,
        'reaction': reaction,
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  // Remove reaction from message
  Future<void> removeReaction(String messageId) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .update({
        'hasReaction': false,
        'reaction': null,
      });
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection(AppConstants.messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromDocument(doc))
            .toList());
  }

  // Stream chat data
  Stream<ChatModel?> streamChat(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ChatModel.fromDocument(doc) : null);
  }

  // Get user's chats
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromDocument(doc))
            .toList()
          ..sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          }));
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
