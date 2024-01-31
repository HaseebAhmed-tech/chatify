import 'package:chatify/auth/login/login_vu.dart';
import 'package:chatify/auth/signup/signup_vu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../ui/home/home_view.dart';

appRoutes() => [
      GetPage(
        name: '/login',
        page: () => const LoginView(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
      GetPage(
        name: '/signup',
        page: () => const SignupView(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
      GetPage(
        name: '/home',
        page: () => const HomeView(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
    ];

class MyMiddelware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    debugPrint(page?.name);
    return super.onPageCalled(page);
  }
}
