import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(250, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
        elevation: 2,
      ),
      icon: const FaIcon(
        FontAwesomeIcons.google,
        color: Colors.red,
        size: 20,
      ),
      label: const Text(
        "Sign in with Google",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }
}
