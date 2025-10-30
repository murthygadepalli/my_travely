import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  Future<AppSettings> fetchAppSettings() async {
    const url = 'https://api.mytravaly.com/public/v1/appSetting/';
    print("🌍 Fetching App Settings from: $url");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authToken': AppConfig.authToken,
        },
      ).timeout(AppConfig.timeout);

      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          print("✅ Settings fetched successfully!");
          return AppSettings.fromJson(data['data']);
        } else {
          print("⚠️ API returned error: ${data['message']}");
          throw Exception(data['message'] ?? "Invalid API response");
        }
      } else {
        throw Exception("❌ Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching app settings: $e");
      throw Exception("Failed to fetch settings: $e");
    }
  }
}
