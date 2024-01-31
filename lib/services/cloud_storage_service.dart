import 'dart:io';
import 'package:path/path.dart';
import 'package:chatify/services/snackbar_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CloudStorageService {
  static final CloudStorageService _instance = CloudStorageService();
  static CloudStorageService get instance => _instance;
  final Reference _baseref;

  CloudStorageService() : _baseref = FirebaseStorage.instance.ref();

  final String _profileImages = 'profile_images';
  final String _messages = 'messages';
  final String _images = 'images';

  Future<UploadTask?> uploadUserImage(String uid, File image) async {
    try {
      UploadTask uploadTask =
          _baseref.child(_profileImages).child(uid).putFile(image);
      await uploadTask.whenComplete(() => SnackBarService.showSnackBar(
          'Success', 'Image Uploaded Successfully'));
      return uploadTask;
    } catch (e) {
      debugPrint('Upload Image Error: $e');
      return null;
    }
  }

  Future<UploadTask?> uploadDefaultUserImage(String uid, String url) async {
    try {
      UploadTask uploadTask =
          _baseref.child(_profileImages).child(uid).putString(url);
      await uploadTask.whenComplete(() => SnackBarService.showSnackBar(
          'Success', 'Image Uploaded Successfully'));
      return uploadTask;
    } catch (e) {
      debugPrint('Upload Image Error: $e');
      return null;
    }
  }

  Future<UploadTask?> uploadMediaMessage(String uid, File file) async {
    try {
      final timestamp = DateTime.now();
      var fileName = basename(file.path);
      // fileName.replaceAll(' ', '_');
      // fileName.replaceAll(':', '_');
      // fileName.replaceAll('/', '_');
      // fileName.replaceAll('\\', '_');
      fileName += '_${timestamp.toString()}';

      UploadTask uploadTask = _baseref
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName)
          .putFile(file);
      await uploadTask.whenComplete(
          () => SnackBarService.showSnackBar('Success', 'Image Sent'));
      return uploadTask;
    } catch (e) {
      debugPrint('Upload Image Error: $e');
      return null;
    }
  }
}
