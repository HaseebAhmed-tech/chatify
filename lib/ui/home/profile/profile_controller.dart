import 'package:chatify/providers/auth_provider.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  Future<void> onLogout(AuthProvider authProvider) async {
    await authProvider.logout(onSuccess);
  }

  Future<void> onSuccess() async {}
}
