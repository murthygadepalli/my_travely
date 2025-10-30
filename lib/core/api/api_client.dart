import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'api_exceptions.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body, {
        String? token,
      }) async {
    final url = Uri.parse("${AppConfig.baseUrl}$endpoint");
    final headers = {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "AuthToken":  "$token",
    };

    try {
      // ✅ Log Request
      print("📡 API REQUEST => $url");
      print("📦 HEADERS => $headers");
      print("📤 BODY => ${jsonEncode(body)}");

      final response = await _client
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(AppConfig.timeout);

      // ✅ Log Response
      print("✅ RESPONSE [${response.statusCode}] => ${response.body}");
      print("✅ RESPONSE [${response.statusCode}] => ${response.body}");


      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API ERROR => $e");
      throw ApiException(e.toString());
    }
  }
}
