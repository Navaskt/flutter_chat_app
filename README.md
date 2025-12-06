# LoveChat 💕

A beautiful, romantic Flutter chat/messaging app designed for private couple communication with an elegant **Pink/Rose Gold** color theme.

## ✨ Features

- 🎨 **Beautiful Romantic UI** - Soft pink and rose gold color scheme with elegant animations
- 💬 **Real-time Messaging** - Instant message delivery using Firebase Firestore
- 📸 **Image Sharing** - Send photos from gallery or camera
- 😊 **Emoji Support** - Built-in emoji picker for expressive conversations
- ✓✓ **Read Receipts** - Know when messages are sent, delivered, and read
- ⌨️ **Typing Indicators** - See when your partner is typing
- 🔔 **Push Notifications** - Get notified of new messages via Firebase Cloud Messaging
- 👤 **Profile Management** - Upload profile pictures and edit personal information
- 🌟 **Online Status** - See when your partner is online or their last seen time
- ❤️ **Message Reactions** - React to messages with heart emojis
- 📅 **Date Dividers** - Messages grouped by date for easy navigation

## 🎨 Color Theme

- **Primary Color**: Soft Pink (#FFB6C1, #FFC0CB)
- **Accent Color**: Rose Gold (#E8B4B8, #B76E79)
- **Background**: Soft white/cream with subtle pink gradients
- **Sent Messages**: Rose gold / soft pink gradient
- **Received Messages**: Light lavender / soft gray

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project (for backend services)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Navaskt/flutter_chat_app.git
   cd flutter_chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable the following Firebase services:
      - Authentication (Email/Password)
      - Cloud Firestore
      - Firebase Storage
      - Firebase Cloud Messaging
   
   c. Install Firebase CLI and FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
   
   d. Configure Firebase for your Flutter app:
   ```bash
   flutterfire configure
   ```
   
   This will generate `lib/config/firebase_options.dart` with your project configuration.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ⚠️ Web (partial support)

## 🏗️ Project Structure

```
lib/
├── main.dart                   # App entry point
├── config/
│   ├── theme.dart             # Romantic theme configuration
│   ├── constants.dart         # App constants
│   └── firebase_options.dart  # Firebase configuration
├── models/
│   ├── user_model.dart        # User data model
│   ├── message_model.dart     # Message data model
│   └── chat_model.dart        # Chat data model
├── services/
│   ├── auth_service.dart      # Authentication logic
│   ├── chat_service.dart      # Chat/messaging logic
│   ├── notification_service.dart  # Push notifications
│   └── storage_service.dart   # File storage
├── screens/
│   ├── splash_screen.dart     # Splash screen
│   ├── onboarding_screen.dart # Onboarding flow
│   ├── home_screen.dart       # Chats list
│   ├── auth/
│   │   ├── login_screen.dart  # Login page
│   │   └── register_screen.dart  # Registration page
│   ├── chat/
│   │   └── chat_screen.dart   # Chat interface
│   └── profile/
│       └── profile_screen.dart  # User profile
├── widgets/
│   ├── chat_bubble.dart       # Message bubble widget
│   ├── message_input.dart     # Message input field
│   ├── typing_indicator.dart  # Typing animation
│   └── avatar_widget.dart     # User avatar
└── utils/
    ├── date_formatter.dart    # Date/time formatting
    └── validators.dart        # Input validation
```

## 🔧 Configuration

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /chat_images/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📦 Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Real-time database
- `firebase_storage` - File storage
- `firebase_messaging` - Push notifications
- `image_picker` - Image selection
- `emoji_picker_flutter` - Emoji picker
- `cached_network_image` - Image caching
- `intl` - Internationalization
- `provider` - State management
- `flutter_local_notifications` - Local notifications
- `google_fonts` - Custom fonts
- `shimmer` - Loading animations
- `lottie` - Lottie animations

## 🎯 Future Enhancements

- [ ] Voice messages
- [ ] Video messages
- [ ] Voice/Video calls
- [ ] Message search
- [ ] Message deletion
- [ ] Dark mode
- [ ] Custom chat themes
- [ ] Backup and restore
- [ ] End-to-end encryption

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🐛 Issues

If you encounter any issues or have suggestions, please [create an issue](https://github.com/Navaskt/flutter_chat_app/issues).

## 💖 Acknowledgments

- Inspired by romantic messaging apps
- Built with Flutter and Firebase
- Uses Material Design 3 principles with a romantic twist

---

Made with ❤️ for couples who want a private, beautiful space to connect