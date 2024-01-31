import 'package:get/get.dart';

class SnackBarService {
  static showSnackBar(String title, String message) {
    Get.snackbar(title, message);
  }
}
