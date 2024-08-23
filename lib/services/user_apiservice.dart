import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetravelfrontend/model/user_model.dart';

class UserApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";
  static const String contactInfoKey = 'contact_info'; // SharedPreferences key
  static const String idKey = 'id'; // SharedPreferences key


  // Fetch Geolocation
  static Future<Map<String, dynamic>> fetchGeolocation() async {
    final response = await http.get(Uri.parse('$baseUrl/geolocation'));

    return _handleResponse(response);
  }




 // Update User Location
  static Future<Map<String, dynamic>> updateUserLocation({
    required String userId,
    required double longitude,
    required double latitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUserLocation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'coordinates': [longitude, latitude],
      }),
    );
    return _handleResponse(response);
  }

  // Sign Up User
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
      }),
    );
    return _handleResponse(response);
  }

  // Sign In User
  static Future<Map<String, dynamic>> signin({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  // Handle response from the API
    // Handle response from the API
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> result = {};
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        try {
          result['data'] = jsonDecode(response.body);
        } catch (e) {
          result['error'] = 'Invalid JSON response: $e';
        }
      } else {
        result['error'] = 'Empty response';
      }
    } else {
      if (response.body.isNotEmpty) {
        try {
          result['error'] = jsonDecode(response.body)['message'];
        } catch (e) {
          result['error'] = 'Invalid JSON error response: $e';
        }
      } else {
        result['error'] = 'Unexpected error with empty response';
      }
    }
    return result;
  }
}
