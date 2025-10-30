import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/device_service.dart';
import '../../../core/repository/settings_repository.dart';
import '../../../core/models/app_settings_model.dart';
import '../../../helper/token_storage.dart';
import '../../hotels/widgets/google_button.dart';
import '../bloc/auth_bloc.dart';

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  AppSettings? appSettings;
  bool isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final repo = SettingsRepository();
      final settings = await repo.fetchAppSettings();
      setState(() {
        appSettings = settings;
        isLoadingSettings = false;
      });
    } catch (e) {
      print("❌ Failed to fetch settings: $e");
      setState(() => isLoadingSettings = false);
    }
  }

  Future<Map<String, dynamic>> buildDeviceBody() async {
    final deviceData = await DeviceInfoHelper.getDeviceInfo();
    return {
      "action": "deviceRegister",
      "deviceRegister": deviceData,
    };
  }


  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('❌ Failed to launch URL: $url — $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            await TokenStorage.saveToken(state.visitorToken);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Device Registered Successfully!")),
            );
            Navigator.pushReplacementNamed(context, Routes.home);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF622A39)),
            );
          }

          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Illustration
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Welcome Text
                    const Text(
                      "Welcome to My Travely",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF622A39),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to start exploring amazing stays!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),

                    // Google Button
                    GoogleButton(
                      onPressed: () async {
                        final body = await buildDeviceBody();
                        context.read<AuthBloc>().add(RegisterDeviceEvent(body));
                      },
                    ),

                    const SizedBox(height: 24),

                    // Terms & Privacy Section
                    if (!isLoadingSettings && appSettings != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "By continuing, you agree to our "),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  color: Color(0xFF622A39),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _openLink(appSettings!.termsUrl),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: Color(0xFF622A39),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _openLink(appSettings!.privacyUrl),
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
