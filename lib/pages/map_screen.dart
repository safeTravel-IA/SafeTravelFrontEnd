import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/pages/top_appbar.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  final TextEditingController _destinationController = TextEditingController();
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserProfile();
    });
  }

  Future<void> _loadLocation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchGeolocation();
    final latitude = double.tryParse(userProvider.latitude ?? '');
    final longitude = double.tryParse(userProvider.longitude ?? '');

    if (latitude != null && longitude != null) {
      setState(() {
        _currentPosition = LatLng(latitude, longitude);
        _markers.clear();
        _markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: _currentPosition!,
            builder: (ctx) => Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
        _mapController.move(_currentPosition!, 14.0);
      });

      // Update the user's location in the backend
      await userProvider.updateUserLocation(latitude, longitude);
    }
  }

  Future<void> _getRouteCoordinates(LatLng start, LatLng destination) async {
    final String apiKey = '5b3ce3597851110001cf6248ee38c464c4c844a092a1f10a44be09cb'; // Replace with your API key
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}';

    setState(() {
      _isLoadingRoute = true;
    });

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

      final List<LatLng> routePoints = coordinates
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          points: routePoints,
          strokeWidth: 4.0,
          color: Colors.green, // Set route color to green
        ));
        _isLoadingRoute = false;
      });
    } else {
      setState(() {
        _isLoadingRoute = false;
      });
      print("Failed to load route");
    }
  }

  void _searchDestination() async {
  final destination = _destinationController.text;
  if (destination.isNotEmpty) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Fetch coordinates for the destination
    await userProvider.fetchLocationCoordinates(destination);
      
    print("Fetched LatitudeD: ${userProvider.latitudeD}");
    print("Fetched LongitudeD: ${userProvider.longitudeD}");

    final latitude = double.tryParse(userProvider.latitudeD ?? '');
    final longitude = double.tryParse(userProvider.longitudeD ?? '');

    if (latitude != null && longitude != null) {
      setState(() {
        _destinationPosition = LatLng(latitude, longitude);

        // Clear and add the new destination marker
        _markers.removeWhere((marker) => marker.point == _destinationPosition);
        _markers.add(
          Marker(
            width: 8,
            height: 8,
            point: _destinationPosition!,
            builder: (ctx) => Icon(
              Icons.location_pin,
              color: Colors.blue, // Set destination marker color to blue
              size: 16.0,
            ),
          ),
        );

        if (_currentPosition != null) {
          _getRouteCoordinates(_currentPosition!, _destinationPosition!);
        }
      });
    } else {
      // Handle error if coordinates are not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch destination coordinates')),
      );
    }
  }


  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showUserProfileDialog(BuildContext context, String imageUrl, String username, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
              SizedBox(height: 16),
              Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(address, style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Define image URL for the profile picture
    final imageUrl = user?.profilePicture != null
        ? 'http://10.0.2.2:3000/api/image/${user!.profilePicture!.replaceFirst('uploads/', '')}'
        : 'assets/images/girl.png';

    return Scaffold(
      appBar: TopAppBar(
        title: 'Map Screen',
        onLogout: () {
          _showLogoutConfirmationDialog(context);
        },
      ),
      body: Column(
        children: [
          // Profile and Notification Icons Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: IconButton(
                    icon: Image.asset('assets/images/user.png'),
                    iconSize: 16, // Adjusted to 16
                    onPressed: () {
                      _showUserProfileDialog(
                        context,
                        imageUrl,
                        user?.username ?? 'Username',
                        user?.address ?? 'No address available',
                      );
                    },
                  ),
                ),
                SizedBox(width: 8), // Add spacing between icons
                Flexible(
                  child: IconButton(
                    icon: Image.asset('assets/images/alert.png'),
                    iconSize: 16, // Adjusted to 16
                    onPressed: () {
                      // Implement notification functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          // Search Destination Field and IconButton
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Enter destination',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchDestination,
                ),
              ],
            ),
          ),
          if (_isLoadingRoute) CircularProgressIndicator(),
          // Use Expanded to make the map take the remaining space
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition ?? LatLng(0, 0),
                zoom: 14.0,
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
                PolylineLayer(
                  polylines: _polylines,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
