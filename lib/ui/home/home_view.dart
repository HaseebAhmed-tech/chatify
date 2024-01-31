import 'package:chatify/resources/constants/styles.dart';
import 'package:chatify/ui/home/profile/profile_view.dart';
import 'package:chatify/ui/home/recents/recents_view.dart';
import 'package:chatify/ui/home/search/search_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../resources/app_theme/theme_provider.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  HomeController get controller => Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeProvider provider, child) {
        return LayoutBuilder(builder: (context, cons) {
          return Scaffold(
            appBar: AppBar(
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text('Chatify'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    provider.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: provider.themeMode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () => controller.changeTheme(provider),
                ),
              ],
              bottom: TabBar(
                controller: controller.tabController,
                unselectedLabelColor: Styles.secondryTextColor,
                indicatorColor: Styles.primaryColor,
                labelColor: Styles.primaryColor,
                tabs: const <Widget>[
                  Tab(
                    icon: Icon(
                      Icons.people_outlined,
                      size: 25,
                      // color: Styles.primaryTextColor,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 25,
                      // color: Styles.primaryTextColor,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.person_outline,
                      size: 25,
                      // color: Styles.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            body: Align(child: _tabBarPages(provider, cons)),
          );
        });
      },
    );
  }

  Widget _tabBarPages(ThemeProvider provider, BoxConstraints cons) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        SearchView(
          cons: cons,
        ),
        RecentsView(
          cons: cons,
        ),
        ProfileView(
          cons: cons,
        )
      ],
    );
  }
}
