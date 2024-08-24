import 'dart:io';
import 'dart:convert'; // For jsonDecode and base64Decode
import 'package:flutter/material.dart';
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
    List<dynamic> _images = [];
  List<dynamic> get images => _images;


  User? get user => _user;
  String? get userId => _userId;
  String? get username => _username; // Add getter for username
  String? get password => _password; // Add getter for password
  String? get errorMessage => _errorMessage;
  String? get latitude => _latitude;
  String? get longitude => _longitude;

    String? get latitudeD => _latitudeD;
  String? get longitudeD => _longitudeD;
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



}
