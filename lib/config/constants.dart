class AppConstants {
  // App Info
  static const String appName = 'LoveChat';
  static const String appTagline = 'Where Hearts Connect ❤️';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  
  // Message Types
  static const String textMessage = 'text';
  static const String imageMessage = 'image';
  
  // Message Status
  static const String messageSent = 'sent';
  static const String messageDelivered = 'delivered';
  static const String messageRead = 'read';
  
  // Typing Status
  static const String typingField = 'isTyping';
  static const String typingTimestampField = 'typingTimestamp';
  
  // Online Status
  static const String onlineField = 'isOnline';
  static const String lastSeenField = 'lastSeen';
  
  // Shared Preferences Keys
  static const String userIdKey = 'userId';
  static const String userEmailKey = 'userEmail';
  static const String userNameKey = 'userName';
  static const String userAvatarKey = 'userAvatar';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxMessageLength = 1000;
  
  // UI Constants
  static const double avatarRadius = 25;
  static const double avatarRadiusLarge = 40;
  static const double borderRadius = 16;
  static const double messageBorderRadius = 20;
  
  // Animation Durations
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const Duration typingAnimationDuration = Duration(milliseconds: 1500);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // Notification Settings
  static const String notificationChannelId = 'lovechat_messages';
  static const String notificationChannelName = 'LoveChat Messages';
  static const String notificationChannelDescription = 'Notifications for new messages';
}
