# LoveChat Setup Guide 🚀

This guide will walk you through setting up the LoveChat Flutter app from scratch.

## Prerequisites

Before you begin, make sure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (3.0.0 or higher)
   - Comes with Flutter

3. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

4. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

5. **Development Environment**
   - Android Studio (for Android development)
   - Xcode (for iOS development, macOS only)
   - VS Code or Android Studio with Flutter plugins

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Navaskt/flutter_chat_app.git
cd flutter_chat_app
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Set Up Firebase

#### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "lovechat")
4. Follow the setup wizard

#### 3.2 Enable Firebase Services

Enable the following services in your Firebase project:

**Authentication:**
1. Go to Authentication → Sign-in method
2. Enable "Email/Password" provider
3. Save changes

**Firestore Database:**
1. Go to Firestore Database
2. Click "Create database"
3. Start in "production mode" (we'll add rules later)
4. Choose a location closest to your users
5. Click "Enable"

**Storage:**
1. Go to Storage
2. Click "Get started"
3. Start in "production mode"
4. Click "Next" and "Done"

**Cloud Messaging:**
1. Go to Project Settings → Cloud Messaging
2. Note down the Server Key (for later use)

#### 3.3 Configure Firebase for Flutter

Run the FlutterFire configuration command:

```bash
flutterfire configure
```

This will:
- Show a list of your Firebase projects
- Let you select which platforms to support (Android, iOS, etc.)
- Automatically generate `lib/config/firebase_options.dart`
- Register your app with Firebase

Select your project and the platforms you want to support.

#### 3.4 Add Firebase Configuration Files

**For Android:**
The `google-services.json` file should be automatically downloaded to `android/app/` directory.

If not, download it manually:
1. Go to Project Settings → Your apps
2. Select your Android app
3. Download `google-services.json`
4. Place it in `android/app/` directory

**For iOS:**
The `GoogleService-Info.plist` file should be automatically downloaded to `ios/Runner/` directory.

If not, download it manually:
1. Go to Project Settings → Your apps
2. Select your iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 4. Configure Firestore Security Rules

Go to Firestore Database → Rules and paste the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat documents
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
    }
    
    // Message documents
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.receiverId);
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.senderId;
    }
  }
}
```

Click "Publish" to apply the rules.

### 5. Configure Storage Security Rules

Go to Storage → Rules and paste the following:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat images
    match /chat_images/{chatId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

Click "Publish" to apply the rules.

### 6. Android-Specific Setup

#### 6.1 Update Android Manifest

Open `android/app/src/main/AndroidManifest.xml` and ensure you have:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application
        android:label="LoveChat"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### 6.2 Update build.gradle

Ensure `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Minimum for Firebase
        targetSdkVersion 33
        multiDexEnabled true
    }
}
```

### 7. iOS-Specific Setup

#### 7.1 Update Info.plist

Open `ios/Runner/Info.plist` and add:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>LoveChat needs access to your photos to send images</string>
<key>NSCameraUsageDescription</key>
<string>LoveChat needs access to your camera to take photos</string>
```

#### 7.2 Update Podfile

Ensure `ios/Podfile` has:

```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios
pod install
cd ..
```

### 8. Run the App

#### For Android:
```bash
flutter run
```

#### For iOS:
```bash
flutter run
```

#### For specific device:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

### 9. Testing

Create test accounts:
1. Run the app
2. Register a new account with email and password
3. Sign in
4. To test chat functionality, create another account on a different device/emulator

## Troubleshooting

### Common Issues

**1. Firebase not initialized**
- Make sure you've run `flutterfire configure`
- Check that `firebase_options.dart` exists in `lib/config/`

**2. Build errors on Android**
- Check `minSdkVersion` is at least 21
- Run `flutter clean` and `flutter pub get`
- Invalidate caches in Android Studio

**3. Pod installation errors on iOS**
- Update CocoaPods: `sudo gem install cocoapods`
- Delete `ios/Podfile.lock` and `ios/Pods`
- Run `pod install` again

**4. Firebase permissions errors**
- Check Firestore and Storage security rules
- Make sure user is authenticated before accessing data

**5. Image picker not working**
- Check permissions in AndroidManifest.xml / Info.plist
- On Android 13+, need specific photo permissions

## Environment Variables

For production, consider using environment variables for sensitive data:

Create `.env` file (not committed to git):
```
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
```

## Next Steps

1. **Customize the app**
   - Change app name in `pubspec.yaml`
   - Update app icon using `flutter_launcher_icons`
   - Customize theme colors in `lib/config/theme.dart`

2. **Test thoroughly**
   - Test on different devices
   - Test different screen sizes
   - Test offline functionality

3. **Deploy**
   - Build release version: `flutter build apk` or `flutter build ios`
   - Submit to Google Play Store / Apple App Store

## Support

For issues and questions:
- Check the [README.md](README.md)
- Open an issue on GitHub
- Review Flutter and Firebase documentation

Happy coding! 💕
