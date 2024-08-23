import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetravelfrontend/services/user_apiservice.dart';
import 'package:safetravelfrontend/model/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _userId;
  String? _username; // Add username field
  String? _password; // Add password field
  String? _errorMessage;
  String? _latitude;
  String? _longitude;

  User? get user => _user;
  String? get userId => _userId;
  String? get username => _username; // Add getter for username
  String? get password => _password; // Add getter for password
  String? get errorMessage => _errorMessage;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  // Sign Up User
  Future<void> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    final response = await UserApiService.signup(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      address: address,
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
}
