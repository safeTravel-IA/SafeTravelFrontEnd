import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';
import 'package:geolocator/geolocator.dart';

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
  String _destinationImageUrl = '';
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
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
    final String apiKey = 'YOUR_OPENROUTESERVICE_API_KEY'; // Replace with your API key
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
          color: Colors.blue,
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

  void _searchDestination() {
    final destination = _destinationController.text;
    if (destination.isNotEmpty) {
      setState(() {
        _destinationPosition = LatLng(37.26667, 9.86666); // Replace with dynamic coordinates

        _markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: _destinationPosition!,
            builder: (ctx) => Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        );

        if (_currentPosition != null && _destinationPosition != null) {
          _getRouteCoordinates(_currentPosition!, _destinationPosition!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenStreetMap Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition ?? LatLng(36.806389, 10.181667),
                  zoom: 14.0,
                ),
                children: [
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
      ),
    );
  }
}
