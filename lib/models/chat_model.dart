import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageType;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, bool> isTyping;
  final Map<String, int> unreadCount;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.lastMessageSenderId,
    Map<String, bool>? isTyping,
    Map<String, int>? unreadCount,
  })  : isTyping = isTyping ?? {},
        unreadCount = unreadCount ?? {};

  // Convert ChatModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'isTyping': isTyping,
      'unreadCount': unreadCount,
    };
  }

  // Create ChatModel from Firestore DocumentSnapshot
  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageType: data['lastMessageType'],
      lastMessageTime: data['lastMessageTime'] != null
          ? DateTime.parse(data['lastMessageTime'])
          : null,
      lastMessageSenderId: data['lastMessageSenderId'],
      isTyping: Map<String, bool>.from(data['isTyping'] ?? {}),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  // Create ChatModel from Map
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageType: map['lastMessageType'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      isTyping: Map<String, bool>.from(map['isTyping'] ?? {}),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  // Create a copy with updated fields
  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageType,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, bool>? isTyping,
    Map<String, int>? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      isTyping: isTyping ?? this.isTyping,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // Get other participant ID
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  // Check if other participant is typing
  bool isOtherTyping(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return isTyping[otherId] ?? false;
  }

  // Get unread count for current user
  int getUnreadCount(String currentUserId) {
    return unreadCount[currentUserId] ?? 0;
  }
}
