import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // 'text' or 'image'
  final String status; // 'sent', 'delivered', 'read'
  final DateTime timestamp;
  final String? imageUrl;
  final bool hasReaction;
  final String? reaction;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.status = 'sent',
    required this.timestamp,
    this.imageUrl,
    this.hasReaction = false,
    this.reaction,
  });

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'hasReaction': hasReaction,
      'reaction': reaction,
    };
  }

  // Create MessageModel from Firestore DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'text',
      status: data['status'] ?? 'sent',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      imageUrl: data['imageUrl'],
      hasReaction: data['hasReaction'] ?? false,
      reaction: data['reaction'],
    );
  }

  // Create MessageModel from Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      status: map['status'] ?? 'sent',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      imageUrl: map['imageUrl'],
      hasReaction: map['hasReaction'] ?? false,
      reaction: map['reaction'],
    );
  }

  // Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    String? type,
    String? status,
    DateTime? timestamp,
    String? imageUrl,
    bool? hasReaction,
    String? reaction,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      hasReaction: hasReaction ?? this.hasReaction,
      reaction: reaction ?? this.reaction,
    );
  }

  // Check if message is sent by current user
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  // Check if message is read
  bool get isRead => status == 'read';

  // Check if message is delivered
  bool get isDelivered => status == 'delivered' || status == 'read';
}
