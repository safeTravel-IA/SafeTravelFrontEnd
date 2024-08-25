import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/pages/destination_plan.dart';
import 'package:safetravelfrontend/pages/top_appbar.dart'; // Import TopAppBar widget
import 'package:safetravelfrontend/providers/user_provider.dart';
import 'package:safetravelfrontend/model/destination_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class DestinationsList extends StatefulWidget {
  @override
  _DestinationsListState createState() => _DestinationsListState();
}

class _DestinationsListState extends State<DestinationsList> {
  late Future<void> _fetchDestinationsFuture;
  List<Destination> _destinations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDestinationsFuture = _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).fetchDestinations();
      setState(() {
        _destinations = Provider.of<UserProvider>(context, listen: false).destinations;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching destinations: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching destinations: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://10.0.2.2:3000/api/image/';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      appBar: TopAppBar(
        title: 'Destination list',
        onLogout: () {
          _showLogoutConfirmationDialog(context);
        },
      ),
      body: Stack(
        children: <Widget>[
          // Top circle
          Positioned(
            top: -50,
            left: -50,
            child: Image.asset(
              'assets/images/top_circle.png',
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Image.asset(
              'assets/images/bottom_circle.png',
              width: 200,
              height: 200,
            ),
          ),
          // Destinations List
          if (_isLoading) 
            Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Center(child: Text(_errorMessage)),
          if (!_isLoading && _errorMessage.isEmpty && _destinations.isNotEmpty)
            ListView.builder(
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final destination = _destinations[index];
                final imageUrl = destination.imageUrl != null
                    ? '$baseUrl${destination.imageUrl}'
                    : 'assets/images/default_image.png'; // Fallback image

                return Card(
                  color: Color(0xFFBCDBDF).withOpacity(0.5), // Set color with 50% opacity
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(destination.name),
                    subtitle: Text(destination.description),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    trailing: IconButton(
                      icon: Image.asset('assets/images/planning.png'),
onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DestinationPlanning(destinationId: destination.id),
    ),
  );
                      },
                    ),
                    onTap: () {
                      // Optional: Handle taps on the ListTile if needed
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/role');
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
}
