import 'dart:async'; // Import for using Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:safetravelfrontend/providers/user_provider.dart';

class ShareLocationScreen extends StatefulWidget {
  @override
  _ShareLocationScreenState createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  String _message = "Location not shared yet.";
  IO.Socket? _socket;
  List<Map<String, dynamic>> _usernames = [];
  List<Map<String, dynamic>> _friends = [];
  Timer? _friendsUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _fetchGeolocation();
    _fetchUsernames();
    _startAutoUpdateFriends(); // Start auto-updating friends list
  }

  // Initialize the Socket.IO connection
  void _initializeSocket() {
    _socket = IO.io(
      'http://10.0.2.2:3000/',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket?.onConnect((_) {
      print('Connected to the server');
      setState(() {
        _message = "Connected to the server.";
      });
    });

    _socket?.on('receive_location', (data) {
      print('Received location: $data');
    });

    _socket?.on('friend_request_received', (data) {
      print('Friend request received: $data');
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from the server');
      setState(() {
        _message = "Disconnected from the server.";
      });
    });

    _socket?.onError((error) {
      print('Connection error: $error');
      setState(() {
        _message = "Connection error: $error";
      });
    });
  }

  // Fetch geolocation
  Future<void> _fetchGeolocation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.fetchGeolocation();

      final latitude = userProvider.latitude;
      final longitude = userProvider.longitude;

      if (latitude != null && longitude != null) {
        setState(() {
          _message = "Location fetched: $latitude, $longitude";
        });
      } else {
        setState(() {
          _message = "Failed to fetch location from provider.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Failed to fetch location: $e";
      });
    }
  }

  // Fetch usernames
  Future<void> _fetchUsernames() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? '';

    if (userId.isNotEmpty) {
      await userProvider.fetchAllUsernames(userId);

      if (userProvider.usernames is List<Map<String, dynamic>>) {
        setState(() {
          _usernames = List<Map<String, dynamic>>.from(userProvider.usernames);
        });
      } else {
        print('Error: Usernames are not in the expected format');
        setState(() {
          _usernames = [];
        });
      }
    } else {
      print('User ID is null or empty');
    }
  }

  // Fetch friends
  Future<void> _fetchFriends() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? '';

    if (userId.isNotEmpty) {
      await userProvider.listFriends(userId: userId);
      setState(() {
        _friends = List<Map<String, dynamic>>.from(userProvider.friends);
      });
    } else {
      print('User ID is null or empty');
    }
  }

  // Start auto-updating friends list every 3 seconds
  void _startAutoUpdateFriends() {
    _fetchFriends(); // Initial fetch
    _friendsUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchFriends();
    });
  }

  // Stop auto-updating friends list
  @override
  void dispose() {
    _socket?.disconnect();
    _friendsUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _shareLocation() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchGeolocation();
      final userId = userProvider.userId ?? '';

      final latitude = userProvider.latitude;
      final longitude = userProvider.longitude;

      if (latitude != null && longitude != null) {
        // Convert locationData to a Map<String, dynamic>
        final locationData = {
          'coordinates': [latitude, longitude], // Send as list of numbers
          '': '',
        };

        await userProvider.shareLocationWithFriends(
          userId: userId,
          locationData: locationData,
        );

        setState(() {
          _message = userProvider.statusMessage ?? "Location shared successfully!";
        });
      } else {
        setState(() {
          _message = "Failed to fetch location from provider.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Failed to share location: $e";
      });
    }
  }

  Future<void> _showMessagesDialog() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId ?? '';

  if (userId.isNotEmpty) {
    await userProvider.fetchMessagesByUserId(userId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Messages'),
          content: userProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : userProvider.errorMessage != null
                  ? Text('Error: ${userProvider.errorMessage}')
                  : Container(
                      width: double.maxFinite, // Ensures the ListView uses available width
                      child: ListView.builder(
                        itemCount: userProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = userProvider.messages[index];
                          return ListTile(
                            title: Text(message['username'] ?? 'Unknown'),
                            subtitle: Text(
                              'Sent At: ${message['sentAt']}\nContent: ${message['content'] ?? 'No Content'}',
                              style: TextStyle(fontFamily: 'monospace'), // Use monospace font for better readability
                              maxLines: null, // Allow multiple lines to be displayed
                              overflow: TextOverflow.visible, // Display all lines
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  } else {
    print('User ID is null or empty');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Location and Manage Friends'),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/mail.png'), // The icon to open messages dialog
            onPressed: _showMessagesDialog,
          ),
          IconButton(
            icon: Image.asset('assets/images/request.png'),
            onPressed: _fetchUsernames,
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _buildFriendsListScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildShareLocationButton(),
            SizedBox(height: 20),
            Expanded(child: _buildUsernamesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildShareLocationButton() {
    return GestureDetector(
      onTap: _shareLocation,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/send-message.png',
              width: 30,
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Share Location',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsListScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return ListTile(
            title: Text(friend['username'] ?? 'Unknown'),
            subtitle: Text(friend['address'] ?? 'No Status'),
          );
        },
      ),
    );
  }

  Widget _buildUsernamesList() {
    return ListView.builder(
      itemCount: _usernames.length,
      itemBuilder: (context, index) {
        final user = _usernames[index];
        final userId = user['id'] ?? ''; // Handle null id
        final username = user['username'] ?? 'Unknown';
        return ListTile(
          title: Text(username),
          trailing: ElevatedButton(
            onPressed: () {
              _addFriend(userId);
            },
            child: Text('Send Request'),
          ),
        );
      },
    );
  }

  void _addFriend(String friendId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId ?? '';

  if (userId.isNotEmpty) {
    // Call addFriend instead of sendFriendRequest
    await userProvider.addFriend(
      userId: userId,
      friendId: friendId,
    );

    setState(() {
      _message = userProvider.statusMessage ?? "Friend added successfully!";
    });
  } else {
    print('User ID is null or empty');
  }
}

}
