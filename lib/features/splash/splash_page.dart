import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_travely/core/models/app_settings_model.dart';
import 'package:my_travely/core/repository/settings_repository.dart';
import 'package:my_travely/helper/token_storage.dart';
import 'package:my_travely/features/auth/ui/sign_in_page.dart';
import 'package:my_travely/features/hotels/ui/home_page.dart';

import '../../config/app_config.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SettingsRepository _settingsRepository = SettingsRepository();
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initApp();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeInAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        ));
    _controller.forward();
  }

  Future<void> _initApp() async {
    try {
      await _settingsRepository.fetchAppSettings();
      debugPrint("✅ App settings loaded successfully.");
    } catch (e) {
      debugPrint("⚠️ Failed to fetch settings: $e");
    }

    await Future.delayed(const Duration(seconds: 3)); // keep splash visible

    if (!mounted) return;

    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // ✅ Restore visitor token globally
      AppConfig.visitorToken = token;
      debugPrint("🔑 Visitor token restored: $token");

      // Navigate directly to HomePage safely
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home,
              (route) => false,
        );
      });
    } else {
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.signIn,
              (route) => false,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF622A39),
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "MyTravaly",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your Stay, Simplified",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: "Poppins",
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
