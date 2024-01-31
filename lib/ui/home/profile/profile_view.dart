import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/database_service.dart';
import 'package:chatify/ui/home/profile/profile_controller.dart';
import 'package:chatify/widgets/long_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../models/contact.dart';
import '../../../resources/constants/styles.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key, required this.cons});
  final BoxConstraints cons;
  @override
  ProfileController get controller => Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Align(alignment: Alignment.center, child: _profilePageUI(cons)));
  }

  _profilePageUI(BoxConstraints cons) {
    return Builder(builder: (context) {
      final authProvider = Provider.of<AuthProvider>(context);

      return authProvider.status != AuthStatus.notAuthenticated
          ? StreamBuilder<Contact>(
              stream:
                  DatabaseService.instance.getUserData(authProvider.user!.uid),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                return !snapshot.hasData
                    ? Center(
                        child: SpinKitWanderingCubes(
                          color: Styles.primaryColor,
                          size: 50,
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: cons.maxHeight * 0.05),
                        height: cons.maxHeight * 0.5,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _userAvatar(userData!.image!),
                            _userName(context, userData.name!),
                            _userEmail(context, userData.email!),
                            _logoutButton(cons, authProvider),
                          ],
                        ),
                      );
              })
          : Center(
              child: SpinKitWanderingCubes(
                color: Styles.primaryColor,
                size: 50,
              ),
            );
    });
  }

  _userAvatar(String imageURL) {
    return Container(
      height: 130,
      width: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(
              imageURL,
            ),
            fit: BoxFit.cover),
      ),
    );
  }

  _userName(BuildContext context, String username) {
    return Text(
      username,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  _userEmail(BuildContext context, String userEmail) {
    return Text(
      userEmail,
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Styles.secondryTextColor,
          ),
    );
  }

  _logoutButton(BoxConstraints cons, AuthProvider authProvider) {
    return LongButton(
      backgroundColor: Styles.errorColor,
      height: cons.maxHeight * 0.06,
      onPressed: () => controller.onLogout(authProvider),
      text: 'Logout',
    );
  }
}
