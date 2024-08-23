import 'dart:convert';

class User {
  String id;
  String username;
  String password;
  String firstName;
  String lastName;
  String phoneNumber;
  String address;
  String? profilePicture; // Optional field for profile picture
  List<String> emergencyContacts;
  Map<String, String> preferences;
  Location location;
  DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    this.profilePicture, // Optional parameter
    required this.emergencyContacts,
    required this.preferences,
    required this.location,
    required this.createdAt,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'], // Handle null case
      emergencyContacts: List<String>.from(json['emergencyContacts'] ?? []),
      preferences: Map<String, String>.from(json['preferences'] ?? {}),
      location: Location.fromJson(json['location'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  // Method to convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicture': profilePicture, // Include profile picture
      'emergencyContacts': emergencyContacts,
      'preferences': preferences,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Location {
  String type;
  List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  // Factory constructor to create Location from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
    );
  }

  // Method to convert Location instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
