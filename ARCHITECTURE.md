# LoveChat Architecture Documentation 🏗️

This document describes the architecture and design patterns used in the LoveChat Flutter app.

## Overview

LoveChat follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: UI screens and widgets
- **Business Logic Layer**: Services and state management
- **Data Layer**: Models and Firebase integration

## Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, UI Components)  │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│       Business Logic Layer          │
│  (Services, State Management)       │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│          Data Layer                 │
│  (Models, Firebase, Local Storage)  │
└─────────────────────────────────────┘
```

## Design Patterns

### 1. Provider Pattern (State Management)

We use the Provider package for state management:

```dart
MultiProvider(
  providers: [
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<ChatService>(create: (_) => ChatService()),
    Provider<StorageService>(create: (_) => StorageService()),
    Provider<NotificationService>(create: (_) => NotificationService()),
  ],
  child: MaterialApp(...)
)
```

**Benefits:**
- Simple dependency injection
- Easy to test
- Efficient rebuilds
- No boilerplate code

### 2. Repository Pattern

Services act as repositories that abstract Firebase operations:

```dart
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) => /* transform data */);
  }
}
```

### 3. Model-View Pattern

- **Models**: Represent data structures with serialization
- **Views**: Flutter widgets that build UI
- **Services**: Handle business logic and data operations

## Directory Structure Explained

### `/lib/config`

Configuration files that define app-wide settings:

- `theme.dart`: Material Theme configuration with romantic colors
- `constants.dart`: App constants (collection names, limits, etc.)
- `firebase_options.dart`: Firebase configuration (auto-generated)

### `/lib/models`

Data models with JSON serialization:

```dart
class MessageModel {
  final String id;
  final String content;
  // ...
  
  Map<String, dynamic> toMap() { /* ... */ }
  factory MessageModel.fromDocument(DocumentSnapshot doc) { /* ... */ }
}
```

**Key Models:**
- `UserModel`: User account information
- `MessageModel`: Chat messages
- `ChatModel`: Chat metadata and state

### `/lib/services`

Business logic and external service integrations:

#### AuthService
Handles user authentication:
- Sign in / Sign up
- Password reset
- User profile management
- Online status updates

#### ChatService
Manages chat functionality:
- Send/receive messages
- Real-time message streaming
- Typing indicators
- Read receipts
- Message reactions

#### StorageService
Handles file uploads:
- Profile pictures
- Chat images
- Progress tracking

#### NotificationService
Push notification management:
- FCM initialization
- Local notifications
- Notification handling

### `/lib/screens`

Full-page UI screens organized by feature:

```
screens/
├── splash_screen.dart         # App launch screen
├── onboarding_screen.dart     # First-time user flow
├── home_screen.dart           # Chat list
├── auth/
│   ├── login_screen.dart      # Login page
│   └── register_screen.dart   # Registration page
├── chat/
│   └── chat_screen.dart       # Chat interface
└── profile/
    └── profile_screen.dart    # User profile
```

### `/lib/widgets`

Reusable UI components:

- `chat_bubble.dart`: Message bubble with gradient
- `message_input.dart`: Message compose field
- `typing_indicator.dart`: Animated typing dots
- `avatar_widget.dart`: User profile picture

### `/lib/utils`

Helper functions and utilities:

- `date_formatter.dart`: Format timestamps
- `validators.dart`: Input validation

## Data Flow

### Sending a Message

```
User Input (ChatScreen)
    ↓
MessageInput Widget
    ↓
ChatService.sendMessage()
    ↓
Firebase Firestore
    ↓
Real-time Update
    ↓
StreamBuilder in ChatScreen
    ↓
ChatBubble Widget
```

### Authentication Flow

```
Login Screen
    ↓
AuthService.signInWithEmailAndPassword()
    ↓
Firebase Authentication
    ↓
Auth State Changes Stream
    ↓
AuthWrapper (main.dart)
    ↓
Navigate to HomeScreen
```

## Firebase Integration

### Firestore Collections

```
firestore
├── users/
│   └── {userId}
│       ├── id: string
│       ├── email: string
│       ├── name: string
│       ├── avatarUrl: string?
│       ├── isOnline: boolean
│       ├── lastSeen: timestamp
│       └── createdAt: timestamp
│
├── chats/
│   └── {chatId}
│       ├── id: string
│       ├── participants: [userId1, userId2]
│       ├── lastMessage: string?
│       ├── lastMessageTime: timestamp?
│       ├── lastMessageSenderId: string?
│       ├── lastMessageType: string?
│       ├── isTyping: {userId: boolean}
│       └── unreadCount: {userId: number}
│
└── messages/
    └── {messageId}
        ├── id: string
        ├── chatId: string
        ├── senderId: string
        ├── receiverId: string
        ├── content: string
        ├── type: string
        ├── status: string
        ├── timestamp: timestamp
        ├── imageUrl: string?
        ├── hasReaction: boolean
        └── reaction: string?
```

### Firebase Storage Structure

```
storage
├── profile_images/
│   └── {userId}.jpg
│
└── chat_images/
    └── {chatId}/
        └── {timestamp}.jpg
```

## State Management Strategy

### Local State (setState)

Used for simple, widget-specific state:
- Form input
- UI animations
- Loading indicators

```dart
bool _isLoading = false;

void _submit() {
  setState(() => _isLoading = true);
  // ...
}
```

### Provider (Dependency Injection)

Used for services and app-wide state:

```dart
// Accessing service
final authService = context.read<AuthService>();

// Using in build method (doesn't rebuild)
final chatService = Provider.of<ChatService>(context, listen: false);
```

### StreamBuilder (Real-time Data)

Used for Firebase real-time updates:

```dart
StreamBuilder<List<MessageModel>>(
  stream: chatService.streamMessages(chatId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return Loading();
    return MessagesList(messages: snapshot.data!);
  },
)
```

## Error Handling

### Service Layer

Services handle errors and throw descriptive exceptions:

```dart
try {
  await _firestore.collection('messages').add(data);
} catch (e) {
  throw Exception('Failed to send message: $e');
}
```

### UI Layer

Screens catch and display errors to users:

```dart
try {
  await authService.signIn(email, password);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString()))
  );
}
```

## Performance Optimizations

### 1. Image Caching
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => Shimmer(...),
)
```

### 2. List View Optimization
```dart
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) => ChatBubble(...),
)
```

### 3. Conditional Rebuilds
```dart
Provider.of<Service>(context, listen: false) // Doesn't rebuild
```

### 4. Const Constructors
```dart
const Text('Hello')  // Reuses widget instance
```

## Security Considerations

### 1. Authentication Required
All Firebase operations require authentication:
```dart
if (currentUserId == null) return;
```

### 2. Server-Side Validation
Firestore rules validate all operations:
```javascript
allow write: if request.auth != null && 
  request.auth.uid in resource.data.participants;
```

### 3. Data Sanitization
User input is validated before submission:
```dart
final validation = Validators.validateEmail(email);
if (validation != null) return;
```

## Testing Strategy

### Unit Tests
Test individual functions and services:
```dart
test('validateEmail returns error for invalid email', () {
  expect(Validators.validateEmail('invalid'), isNotNull);
});
```

### Widget Tests
Test UI components in isolation:
```dart
testWidgets('ChatBubble displays message', (tester) async {
  await tester.pumpWidget(ChatBubble(...));
  expect(find.text('Hello'), findsOneWidget);
});
```

### Integration Tests
Test complete user flows:
```dart
testWidgets('User can send message', (tester) async {
  // Navigate to chat screen
  // Enter message
  // Tap send button
  // Verify message appears
});
```

## Future Architecture Improvements

1. **MVVM Pattern**: Introduce ViewModels for complex screens
2. **Repository Layer**: Abstract Firebase completely
3. **Offline-First**: Local database with sync
4. **Modular Architecture**: Feature-based modules
5. **Dependency Injection**: Use get_it for better DI
6. **BLoC Pattern**: For complex state management

## Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **DRY (Don't Repeat Yourself)**: Reusable components and services
3. **SOLID Principles**: Clean, maintainable code
4. **Responsive Design**: Adapts to different screen sizes
5. **Accessibility**: Support for screen readers and accessibility features
6. **Performance**: Optimized for 60fps
7. **Security**: Authentication and authorization at every level

## Contributing

When adding new features:
1. Follow existing patterns
2. Keep services focused and single-purpose
3. Reuse existing widgets when possible
4. Add proper error handling
5. Document complex logic
6. Write tests for new functionality

---

For questions about the architecture, please open an issue on GitHub.
