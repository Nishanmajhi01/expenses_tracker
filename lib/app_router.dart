import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/create_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String createAccount = '/createAccount';
  static const String forgotPassword = '/forgotPassword';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settingsPage = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRouter.settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
