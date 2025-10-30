
import '../../../config/app_config.dart';
import '../../core/api/api_actions.dart';
import '../../core/api/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<String> registerDevice(Map<String, dynamic> deviceBody) async {
    final response = await _apiClient.post(
      ApiEndpoints.registerDevice,
      deviceBody,
      token: AppConfig.authToken,
    );

    if (response['status'] == true && response['data'] != null) {
      final visitorToken = response['data']['visitorToken'] ?? '';

      // 👇 Store globally for later use
      AppConfig.visitorToken = visitorToken;

      print('✅ Visitor token saved: $visitorToken');
      return visitorToken;
    } else {
      throw Exception(response['message'] ?? 'Device registration failed');
    }
  }
}
