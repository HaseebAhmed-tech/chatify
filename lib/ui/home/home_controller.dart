import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../resources/app_theme/theme_provider.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  @override
  void onInit() {
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    );
    super.onInit();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  late final TabController? tabController;

  void changeTheme(ThemeProvider provider) {
    bool isLight = provider.isLight;

    isLight = !isLight;
    isLight
        ? provider.changeAppTheme('light')
        : provider.changeAppTheme('dark');
  }
}
