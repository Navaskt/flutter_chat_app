import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$userId.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload chat image
  Future<String> uploadChatImage(String chatId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child(AppConstants.chatImagesPath)
          .child(chatId)
          .child('$timestamp.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Get upload progress stream
  Stream<double> uploadWithProgress(File file, String path) {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);

    return uploadTask.snapshotEvents.map((snapshot) {
      // Handle edge case where totalBytes might be 0
      if (snapshot.totalBytes == 0) {
        return 0.0;
      }
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}
