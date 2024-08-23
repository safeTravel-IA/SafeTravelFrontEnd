import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

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

  // Sign Up User with optional profile picture
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    String? profilePicturePath, // Profile picture path as a string
  }) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/signup'));

      // Add the text fields
      request.fields['username'] = username;
      request.fields['password'] = password;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['address'] = address;

      // Add the profile picture file if it's provided
      if (profilePicturePath != null && File(profilePicturePath).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicturePath,
          // No need to set contentType explicitly; http.MultipartFile handles it automatically
        ));
      }

      // Send the request
      var response = await request.send();

      // Parse the response
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'data': responseData};
      } else {
        return {'error': responseData['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }


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

 // Method to fetch user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(idKey);

      if (userId == null) {
        return {'error': 'User ID not found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

static Future<Map<String, dynamic>> fetchLocationCoordinates(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$location'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = _handleResponse(response);

      if (result.containsKey('data')) {
        // Assuming the response contains 'latitude' and 'longitude' fields
        final data = result['data'];
        final latitude = data['lat'];
        final longitude = data['lon'];
        return {'lat': latitude, 'lon': longitude};
      } else {
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
