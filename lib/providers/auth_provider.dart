import 'package:chatify/services/database_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/snackbar_service.dart';

enum AuthStatus {
  notAuthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider();
  User? _user;
  AuthStatus status;
  final FirebaseAuth _auth;

  AuthProvider()
      : _auth = FirebaseAuth.instance,
        status = AuthStatus.notAuthenticated {
    _checkCurrentUserIsAuthenticated();
  }
  static AuthProvider get instance => _instance;
  User? get user => _user;

  _autoLogin() async {
    if (_user != null) {
      await DatabaseService.instance.updateUserLastSeenTime(_user!.uid);
      NavigationService.navigateToReplacement('home');
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    _user = _auth.currentUser;
    if (_user != null) {
      status = AuthStatus.authenticated;
      notifyListeners();
      await _autoLogin();
    }
  }

  void loginUserWithEmailandPassword(String email, String password) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      status = AuthStatus.authenticated;
      SnackBarService.showSnackBar(
          'Login Successful', 'Welcome ${_user!.email}');
      await DatabaseService.instance.updateUserLastSeenTime(_user!.uid);
      NavigationService.navigateToReplacement('home');
      debugPrint('Login Status: Logged In Successfuly');
    } catch (e) {
      status = AuthStatus.error;
      SnackBarService.showSnackBar('Login Failed', e.toString());
      _user = null;
      debugPrint('Login Error: ${e.toString()}');
    }
    notifyListeners();
  }

  void registerUserWithEmailandPassword(String email, String password,
      String username, Future<void> Function(String uid) onSuccess) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      status = AuthStatus.authenticated;
      await onSuccess(_user!.uid);
      SnackBarService.showSnackBar(
          'Registration Successful', 'Welcome ${_user!.email}');
      await DatabaseService.instance.updateUserLastSeenTime(user!.uid);
      Get.back();

      debugPrint('Registration Status: Logged In Successfuly');
    } catch (e) {
      status = AuthStatus.error;
      _user = null;
      SnackBarService.showSnackBar('Registration Failed', e.toString());

      debugPrint('Registration Error: ${e.toString()}');
    }
    notifyListeners();
  }

  Future<void> logout(Future<void> Function() onSuccess) async {
    try {
      await _auth.signOut();
      status = AuthStatus.notAuthenticated;

      _user = null;
      await onSuccess();
      SnackBarService.showSnackBar('Logout Successful', 'Goodbye');
      NavigationService.navigateToReplacement('login');
      debugPrint('Logout Status: Logged Out Successfuly');
    } catch (e) {
      debugPrint('Logout Error: ${e.toString()}');
      SnackBarService.showSnackBar('Logout Error', 'Unable to Logout');
    }
    notifyListeners();
  }
}
