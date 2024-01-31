import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static final MediaService _instance = MediaService();
  static get instance => _instance;

  Future<File?> getImageFromLibrary() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Image Picker Error: $e');
      return null;
    }
  }
}
