import 'package:chatify/firebase_options.dart';
import 'package:chatify/resources/app_theme/theme_provider.dart';
import 'package:chatify/resources/constants/routes.dart';
import 'package:chatify/resources/constants/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // name: "Chatify",
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then(
    (value) => runApp(
      const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider.instance,
      builder: (_, __) => Consumer(
        builder: (context, ThemeProvider themeProvider, child) {
          return GetMaterialApp(
            title: 'Chatify',
            theme: ThemesData.reqThemeData(themeProvider.themeMode),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            getPages: appRoutes(),
            initialRoute: '/login',
          );
        },
      ),
    );
  }
}
