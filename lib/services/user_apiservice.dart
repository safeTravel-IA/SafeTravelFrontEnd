import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:safetravelfrontend/model/destination_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

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

  // Fetch Images from Unsplash
static Future<Map<String, dynamic>> fetchImages(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/about/images/$query'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = _handleResponse(response);

      // Process and return image URLs
      if (result.containsKey('images')) {
        List<dynamic> images = result['images'];
        List<String> rawUrls = [];
        List<String> fullUrls = [];

        for (var image in images) {
          if (image['raw'] != null) {
            rawUrls.add(image['raw']);
          }
          if (image['full'] != null) {
            fullUrls.add(image['full']);
          }
        }

        return {
          'rawUrls': rawUrls,
          'fullUrls': fullUrls,
        };
      } else {
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
// Fetch Weather Alerts by Location
static Future<Map<String, dynamic>> getWeatherAlerts(String destination, double? lat, double? lon) async {
  try {
    final body = {
      'destination': destination, // Optional
      // Only include lat and lon if they are not null
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon
    };

    final response = await http.post(
      Uri.parse('$baseUrl/weather/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  } catch (e) {
    return {'error': e.toString()};
  }
}


static Future<http.Response> fetchUserImages(String urls) async {
    final url = Uri.parse('$baseUrl/user/images?urls=$urls');
    return await http.get(url);
  }


Future<List<Destination>> fetchDestinations() async {
  final response = await http.get(Uri.parse('$baseUrl/destination/list'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success']) {
      List<dynamic> destinations = data['data'];
      return destinations.map((destination) => Destination.fromJson(destination)).toList();
    } else {
      throw Exception('Failed to load destinations: ${data['message']}');
    }
  } else {
    throw Exception('Failed to load destinations');
  }
}


  // Method to create a new planning entry
  static Future<Map<String, dynamic>> createPlanning({
    required String userId,
    required String destinationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plannings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'destinationId': destinationId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'userId': userId, // Include userId in the request body
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }


  // Convert Currency method
  static Future<Map<String, dynamic>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/convertion/convert?amount=$amount&from=$fromCurrency&to=$toCurrency'),
        headers: {'Content-Type': 'application/json'},
      );

      // Parse the response body
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Extract conversion data
        final double convertedAmount = data['convertedAmount']?.toDouble() ?? 0.0;
        final double rate = data['rate']?.toDouble() ?? 0.0;

        return {
          'convertedAmount': convertedAmount,
          'rate': rate,
        };
      } else {
        // Handle non-200 response
        return {'error': 'Failed to load data'};
      }
    } catch (e) {
      // Handle exceptions
      return {'error': e.toString()};
    }
  }


  static Future<Map<String, dynamic>> translateText({
    required String text,
    required String from,
    required String to,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'from': from,
          'to': to,
          'userId': userId, // Include userId in the request body
        }),
      );

      final Map<String, dynamic> result = {};
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode the response body
        result['data'] = jsonDecode(response.body);
      } else {
        // Handle non-200 response
        result['error'] = jsonDecode(response.body)['error'] ?? 'Failed to translate text';
      }

      return result;
    } catch (e) {
      // Handle exceptions
      return {'error': e.toString()};
    }
  }
static Future<Map<String, dynamic>> createForumPost({
    required String userId,
    required String destinationId,
    required String title,
    required String content,
    required List<String> hashtags,
    String? imagePath, // Optional image path
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/forum/create'));

      // Add text fields
      request.fields['userId'] = userId;
      request.fields['destinationId'] = destinationId;
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['hashtags'] = jsonEncode(hashtags);

      // Add image if provided
      if (imagePath != null && File(imagePath).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ));
      }

      // Send request and get the response
      var response = await request.send();
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

  // Get All Forum Posts
  static Future<Map<String, dynamic>> getAllForumPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/forum/getA'));
      return _handleResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get Forum Post By ID
  static Future<Map<String, dynamic>> getForumPostById(String postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/forum/$postId'));
      return _handleResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Delete Forum Post
  static Future<Map<String, dynamic>> deleteForumPost(String postId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/forum/$postId'));
      return _handleResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

    // Method to update a forum post
  static Future<Map<String, dynamic>> updateForumPost({
    required String postId,
    required String title,
    required String content,
    String? imagePath, // Optional image path
  }) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/forum/$postId'),
      );

      // Add the text fields
      request.fields['title'] = title;
      request.fields['content'] = content;

      // Add the image file if it's provided
      if (imagePath != null && File(imagePath).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
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
        return {'error': responseData['message'] ?? 'Failed to update post'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

