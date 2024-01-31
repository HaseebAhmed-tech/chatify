import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationService {
  static navigateToReplacement(String routeName, {dynamic arguments}) {
    return Get.offAndToNamed('/$routeName', arguments: arguments);
  }

  static navigateTo(String routeName, {dynamic arguments}) {
    return Get.toNamed('/$routeName', arguments: arguments);
  }

  static navigateToRoute(MaterialPageRoute route) {
    return Get.to(route);
  }

  static goBack() {
    return Get.back();
  }
}
