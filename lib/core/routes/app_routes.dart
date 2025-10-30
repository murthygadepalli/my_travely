import 'package:flutter/material.dart';
import '../../features/auth/ui/sign_in_page.dart';
import '../../features/hotels/ui/home_page.dart';
import '../../features/splash/splash_page.dart';

class Routes {
  static const String splash = '/splash';
  static const String signIn = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getAll() => {
    splash: (_) => const SplashScreen(),
    signIn: (_) => const GoogleSignInPage(),
    home: (_) => const HomePage(),
  };
}
