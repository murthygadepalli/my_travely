import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as _apiClient;
import '../../../core/models/hotel_model.dart';
import '../../config/app_config.dart';
import '../api/api_actions.dart';
import '../models/currency_model.dart';

class HotelRepository {






  Future<List<Hotel>> fetchHotels(Map<String, dynamic> body) async {
    final url = Uri.parse(AppConfig.baseUrl);
    print('➡️ API Requesting: $url');
    print('📦 Request Body: ${jsonEncode(body)}');

    final visitorToken = AppConfig.visitorToken;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authToken': AppConfig.authToken,
        'visitorToken': visitorToken.toString(),
      },
      body: jsonEncode(body),
    ).timeout(AppConfig.timeout);

    print('📥 Response Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == true && jsonData['data'] != null) {
        // ✅ Handle both popularStay and searchResultListOfHotels
        List data = [];
        if (jsonData['data'] is List) {
          data = jsonData['data'];
        } else if (jsonData['data']['arrayOfHotelList'] != null) {
          data = jsonData['data']['arrayOfHotelList'];
        }

        return data.map((hotel) => Hotel.fromJson(hotel)).toList();
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch hotels');
      }
    } else {
      throw Exception('Failed with status code ${response.statusCode}');
    }
  }

  // Future<List<Hotel>> fetchHotels(Map<String, dynamic> body) async {
  //   final url = Uri.parse('${AppConfig.baseUrl}');
  //   print('➡️ API Requesting: $url');
  //   print('📦 Request Body: ${jsonEncode(body)}');
  //
  //   // Ensure visitorToken is available
  //   final visitorToken = AppConfig.visitorToken; // You should store this after registration
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'authToken': AppConfig.authToken,
  //       'visitorToken': visitorToken.toString(), // 👈 add this line
  //     },
  //     body: jsonEncode(body),
  //   ).timeout(AppConfig.timeout);
  //
  //   print('📥 Response Code: ${response.statusCode}');
  //   print('📥 Response Body: ${response.body}');
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final jsonData = jsonDecode(response.body);
  //
  //     if (jsonData['status'] == true && jsonData['data'] != null) {
  //       List data = jsonData['data'];
  //       return data.map((hotel) => Hotel.fromJson(hotel)).toList();
  //     } else {
  //       throw Exception(jsonData['message'] ?? 'Failed to fetch hotels');
  //     }
  //   } else {
  //     throw Exception('Failed with status code ${response.statusCode}');
  //   }
  // }



  Future<List<Map<String, dynamic>>> fetchAutoComplete(String input) async {
    final url = Uri.parse(AppConfig.baseUrl);

    final body = {
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": input,
        "searchType": [
          "byCity",
          "byState",
          "byCountry",
          "byPropertyName",
          "byRandom"
        ],
        "limit": 10
      }
    };

    print("🔍 AutoComplete Request Body: ${jsonEncode(body)}");

    final visitorToken = AppConfig.visitorToken;

    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authToken': AppConfig.authToken,
        'visitorToken': visitorToken.toString(),
      },
      body: jsonEncode(body),
    )
        .timeout(AppConfig.timeout);

    print("📥 AutoComplete Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == true &&
          jsonData['data']?['autoCompleteList'] != null) {
        final result = <Map<String, dynamic>>[];
        final autoList = jsonData['data']['autoCompleteList'];

        autoList.forEach((type, group) {
          if (group['present'] == true) {
            for (var item in group['listOfResult']) {
              result.add({
                "type": type,
                "value": item['valueToDisplay'],
                "address": item['address'] ?? {},
                "searchArray": item['searchArray'],
              });
            }
          }
        });
        return result;
      } else {
        return [];
      }
    } else {
      throw Exception(
          "Autocomplete request failed with status ${response.statusCode}");
    }
  }



  Future<List<Currency>> fetchCurrencyList() async {
    final url = Uri.parse("${AppConfig.baseUrl}");
    print("🌍 Fetching currency list from: $url");

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'authToken': AppConfig.authToken,
    });

    print("📥 Currency API Status: ${response.statusCode}");
    print("📥 Currency API Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true && jsonData['data'] != null) {
        print("✅ Currency list loaded successfully!");
        return Currency.fromList(jsonData['data']);
      } else {
        print("⚠️ Currency API returned invalid data: ${jsonData['message']}");
      }
    } else {
      print("❌ Currency API failed with code ${response.statusCode}");
    }

    throw Exception("Failed to load currency list");
  }


}
