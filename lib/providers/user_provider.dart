import 'dart:io';
import 'dart:convert'; // For jsonDecode and base64Decode
import 'package:flutter/material.dart';
import 'package:safetravelfrontend/model/destination_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetravelfrontend/services/user_apiservice.dart';
import 'package:safetravelfrontend/model/user_model.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:path_provider/path_provider.dart'; // For getTemporaryDirectory

class UserProvider with ChangeNotifier {
  User? _user;
  String? _userId;
  String? _username; // Add username field
  String? _password; // Add password field
  String? _errorMessage;
  String? _latitude;
  String? _longitude;
  String? _latitudeD;
  String? _longitudeD;
    // State variables
  String? _conversionError;
  double? _convertedAmount;
  double? _conversionRate;
  Map<String, dynamic>? _updatedPost;

    List<dynamic> _images = [];
  List<dynamic> get images => _images;
    List<String>? _pollutionAlerts; // For pollution alerts
  List<String>? _weatherAlerts; // Update to a List<String> for alerts
  String? _error;
    List<String>? get pollutionAlerts => _pollutionAlerts;
  // Getters
  String? get conversionError => _conversionError;
  double? get convertedAmount => _convertedAmount;
  double? get conversionRate => _conversionRate;
  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;
 Map<String, dynamic>? get updatedPost => _updatedPost;
  String? get error => _error;
  User? get user => _user;
  String? get userId => _userId;
  String? get username => _username; // Add getter for username
  String? get password => _password; // Add getter for password
  String? get errorMessage => _errorMessage;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  List<String>? get weatherAlerts => _weatherAlerts;

    String? get latitudeD => _latitudeD;
  String? get longitudeD => _longitudeD;
  String? _translationResult;
  String? get translationResult => _translationResult;

  // State variable to store errors
  String? _translationError;
  String? get translationError => _translationError;
  // Sign Up User
   Future<void> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    String? profilePicturePath, // Optional profile picture path
  }) async {
    final response = await UserApiService.signup(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      address: address,
      profilePicturePath: profilePicturePath, // Pass the profile picture path
    );

    if (response.containsKey('data')) {
      _errorMessage = null; // Clear previous error
      notifyListeners();
    } else if (response.containsKey('error')) {
      _errorMessage = response['error'];
      notifyListeners();
    }
  }

  // Sign In User
  Future<void> signin({
    required String username,
    required String password,
  }) async {
    final response = await UserApiService.signin(
      username: username,
      password: password,
    );

    if (response.containsKey('data')) {
      _errorMessage = null; // Clear previous error
      _userId = response['data']['userId'];
      _username = username; // Store username
      _password = password; // Store password

      await _saveUserIdToSharedPreferences(_userId!);
      notifyListeners();
    } else if (response.containsKey('error')) {
      _errorMessage = response['error'];
      notifyListeners();
    }
  }



   Future<void> fetchGeolocation() async {
    final response = await UserApiService.fetchGeolocation();

    if (response.containsKey('data')) {
      _latitude = response['data']['latitude'];
      _longitude = response['data']['longitude'];
      _errorMessage = null; // Clear previous error
      notifyListeners();
    } else if (response.containsKey('error')) {
      _errorMessage = response['error'];
      notifyListeners();
    }
  }

  // Save User Details Locally (Username and Password)
  Future<void> saveUserDetailsLocally() async {
    if (_userId != null && _username != null && _password != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _userId!);
      await prefs.setString('username', _username!);
      await prefs.setString('password', _password!);
    }
  }

// Update User Location
  Future<void> updateUserLocation(double latitude, double longitude) async {
  if (_userId == null || latitude == null || longitude == null) {
    _errorMessage = 'User ID or location is missing';
    notifyListeners();
    return;
  }

  final response = await UserApiService.updateUserLocation(
    userId: _userId!,
    latitude: latitude,
    longitude: longitude,
  );

  if (response.containsKey('data')) {
    _errorMessage = null; // Clear previous error
    notifyListeners();
  } else if (response.containsKey('error')) {
    _errorMessage = response['error'];
    notifyListeners();
  }
}
Future<void> fetchUserProfile() async {
  try {
    final response = await UserApiService.getProfile();

    if (response.containsKey('data')) {
      _user = User.fromJson(response['data']); // Assuming User.fromJson exists
      _errorMessage = null; // Clear previous errors
    } else if (response.containsKey('error')) {
      _errorMessage = response['error']; // Handle error
    }

    notifyListeners(); // Notify listeners to update UI
  } catch (e) {
    _errorMessage = 'Failed to fetch user profile: ${e.toString()}';
    notifyListeners(); // Notify listeners about the error
  }
}
  // Load User ID from SharedPreferences
  Future<void> loadUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    _password = prefs.getString('password');
    notifyListeners();
  }

  // Save User ID to SharedPreferences
  Future<void> _saveUserIdToSharedPreferences(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(UserApiService.idKey, userId);
  }

  // Clear User Data (Logout)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    _userId = null;
    _username = null;
    _password = null;
    _user = null;
    notifyListeners();
  }

   // Fetch Location Coordinates
  Future<void> fetchLocationCoordinates(String location) async {
    final response = await UserApiService.fetchLocationCoordinates(location);

    print("Response: ${response.toString()}"); // Log the full response

    if (response.containsKey('lat') && response.containsKey('lon')) {
      _latitudeD = response['lat'];
      _longitudeD = response['lon'];
      _errorMessage = null;
    } else if (response.containsKey('error')) {
      _errorMessage = response['error'];
    }

    notifyListeners();
  }

Future<void> fetchImages(String query) async {
  _images = [];
  _errorMessage = null;

  final response = await UserApiService.fetchImages(query);

  if (response.containsKey('rawUrls') && response.containsKey('fullUrls')) {
    List<String> rawUrls = List<String>.from(response['rawUrls']);
    List<String> fullUrls = List<String>.from(response['fullUrls']);

    // Combine raw and full URLs into a list of maps
    _images = rawUrls.map((url) => {'url': url, 'type': 'raw'}).toList()
        ..addAll(fullUrls.map((url) => {'url': url, 'type': 'full'}).toList());
  } else if (response.containsKey('error')) {
    _errorMessage = response['error'];
  }

  notifyListeners();
}


 Future<void> fetchUserImages(String urls) async {
  try {
    final response = await UserApiService.fetchUserImages(urls); // Ensure this returns http.Response

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result.containsKey('images')) {
        _images = result['images'].map((img) => {
          'url': img['url'],
          'base64': img['base64Image'],
        }).toList();
        notifyListeners();
      } else {
        _errorMessage = result['error'] ?? 'No images found';
        notifyListeners();
      }
    } else {
      _errorMessage = 'Error fetching images: ${response.reasonPhrase}';
      notifyListeners();
    }
  } catch (e) {
    _errorMessage = 'Error: $e';
    notifyListeners();
  }
}
Future<void> fetchWeatherAlerts(String destination, [double? lat, double? lon]) async {
  // Reset state before making the request
  _weatherAlerts = null;
  _pollutionAlerts = null;
  _error = null;
  notifyListeners();

  // Handle the API call with optional lat and lon
  final result = await UserApiService.getWeatherAlerts(destination, lat, lon);

  if (result.containsKey('error')) {
    _error = result['error'];
  } else {
    // Handle the response data
    final data = result['data'];

    if (data != null && data.containsKey('message')) {
      _weatherAlerts = List<String>.from(data['weatherAlerts']); // Extract weather alerts
      _pollutionAlerts = List<String>.from(data['pollutionAlerts']); // Extract pollution alerts
    } else {
      _weatherAlerts = [];
      _pollutionAlerts = [];
    }
  }

  notifyListeners();
}


  Future<void> fetchDestinations() async {
    try {
      List<Destination> fetchedDestinations = await UserApiService().fetchDestinations();
      _destinations = fetchedDestinations;
      notifyListeners(); // Notify UI to update when data is fetched
    } catch (error) {
      print('Error fetching destinations: $error');
      throw error;
    }
  }
// Method to create a new planning entry
  Future<void> createPlanning({
    required String userId,
    required String destinationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await UserApiService.createPlanning(
        userId: userId,
        destinationId: destinationId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.containsKey('error')) {
        // Handle the error, possibly update state or show a message
        throw Exception(response['error']);
      } else {
        // If needed, update the state with the new planning data
        final planningData = response['data'];
        // Update your state if necessary here
        notifyListeners(); // Notify listeners of any changes
      }
    } catch (e) {
      // Handle exceptions or errors
      print('Error creating planning: $e');
      throw e; // Re-throw the error if needed
    }
  }
// Convert Currency method
// Convert Currency method
  Future<Map<String, dynamic>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Reset previous values
    _conversionError = null;
    _convertedAmount = null;
    _conversionRate = null;
    notifyListeners();

    Map<String, dynamic> response = {};

    try {
      // Call the API service
      final result = await UserApiService.convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

      if (result.containsKey('error')) {
        _conversionError = result['error'];
        response['error'] = result['error'];
      } else {
        // Update state with the conversion result
        _conversionRate = result['rate'];
        _convertedAmount = result['convertedAmount'];
        
        // Add the conversion results to the response map
        response['rate'] = _conversionRate;
        response['convertedAmount'] = _convertedAmount;
      }
    } catch (e) {
      _conversionError = e.toString();
      response['error'] = e.toString();
    }

    // Notify listeners to update the UI
    notifyListeners();

    // Return the response with conversion data or error
    return response;
  }

  
  Future<void> translateText({
    required String text,
    required String from,
    required String to,
    required String userId, // Add the userId parameter here
  }) async {
    if (userId.isEmpty) {
      _translationError = 'User ID is not available';
      notifyListeners();
      return;
    }

    try {
      final response = await UserApiService.translateText(
        text: text,
        from: from,
        to: to,
        userId: userId, // Pass the userId to your API service
      );

      if (response.containsKey('data')) {
        _translationResult = response['data']['translatedText']; // Assuming 'translatedText' is returned
        _translationError = null; // Clear any previous error
      } else if (response.containsKey('error')) {
        _translationError = response['error'];
        _translationResult = null; // Clear any previous result
      }
    } catch (e) {
      _translationError = 'Failed to translate text: ${e.toString()}';
      _translationResult = null; // Clear any previous result
    }

    notifyListeners(); // Notify listeners to update the UI
  }

    Future<Map<String, dynamic>> createForumPost({
    required String userId,
    required String destinationId,
    required String title,
    required String content,
    required List<String> hashtags,
    String? imagePath, // Optional image path
  }) async {
    try {
      final result = await UserApiService.createForumPost(
        userId: userId,
        destinationId: destinationId,
        title: title,
        content: content,
        hashtags: hashtags,
        imagePath: imagePath,
      );

      if (result.containsKey('data')) {
        // Post created successfully
        notifyListeners(); // Notify listeners if needed (e.g., to update UI)
        return result;
      } else {
        // Handle error
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  Future<List<dynamic>> fetchPostData() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/forum/getA'));
  if (response.statusCode == 200) {
    // Decode the response body as a list of dynamic
    return json.decode(response.body) as List<dynamic>;
  } else {
    throw Exception('Failed to load post data');
  }
}


  // Get All Forum Posts
  Future<Map<String, dynamic>> getAllForumPosts() async {
    try {
      final result = await UserApiService.getAllForumPosts();

      if (result.containsKey('data')) {
        // Forum posts retrieved successfully
        notifyListeners(); // Notify listeners to update UI
        return result;
      } else {
        // Handle error
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get Forum Post By ID
  Future<Map<String, dynamic>> getForumPostById(String postId) async {
    try {
      final result = await UserApiService.getForumPostById(postId);

      if (result.containsKey('data')) {
        // Forum post retrieved successfully
        notifyListeners(); // Notify listeners to update UI
        return result;
      } else {
        // Handle error
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Delete Forum Post
  Future<Map<String, dynamic>> deleteForumPost(String postId) async {
    try {
      final result = await UserApiService.deleteForumPost(postId);

      if (result.containsKey('data')) {
        // Forum post deleted successfully
        notifyListeners(); // Notify listeners to update UI
        return result;
      } else {
        // Handle error
        return {'error': result['error']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Method to update a forum post
  // Method to update a forum post
  Future<Map<String, dynamic>> updateForumPost({
    required String postId,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    // Reset previous error
    _error = null;
    notifyListeners();

    // Call the API service method
    final result = await UserApiService.updateForumPost(
      postId: postId,
      title: title,
      content: content,
      imagePath: imagePath,
    );

    // Handle the result
    if (result.containsKey('data')) {
      _updatedPost = result['data'];
      notifyListeners();
      return {'success': true};
    } else {
      _error = result['error'];
      notifyListeners();
      return {'error': _error};
    }
  }
}
