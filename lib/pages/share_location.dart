// ShareLocationScreen.dart
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
  List<Map<String, dynamic>> _friends = []; // Store friends list

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _fetchGeolocation();
    _fetchUsernames();
    _fetchFriends(); // Fetch friends list
    
  }

  // Initialize the Socket.IO connection
  void _initializeSocket() {
    _socket = IO.io(
      'http://10.0.2.2:3000/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .build(),
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
      // Update the UI or notify user about the new friend request
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
      await userProvider.fetchGeolocation(); // Call the provider's method

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


  // Fetch usernames and friends
  Future<void> _fetchUsernames() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId != null && userId.isNotEmpty) {
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

  Future<void> _fetchFriends() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId != null && userId.isNotEmpty) {
      await userProvider.listFriends(userId: userId);
      setState(() {
        _friends = List<Map<String, dynamic>>.from(userProvider.friends); // Assume you have a friends list in UserProvider
      });
    } else {
      print('User ID is null or empty');
    }
  }

  // Function to share location
  Future<void> _shareLocation() async {
    try {
      final locationProvider = Provider.of<UserProvider>(context, listen: false);
      await locationProvider.fetchGeolocation();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId ?? "";

      final latitude = locationProvider.latitude;
      final longitude = locationProvider.longitude;

      if (latitude != null && longitude != null) {
        String locationMessage =
            'https://maps.google.com/?q=$latitude,$longitude';

        _socket?.emit('share_location', {
          'latitude': latitude,
          'longitude': longitude,
          'message': locationMessage,
        });

        await locationProvider.shareLocationWithFriends(
          userId: userId,
          locationData: {'latitude': latitude, 'longitude': longitude},
        );

        setState(() {
          _message = "Location shared successfully!";
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

  // Accept friend request
  void _acceptFriend(String friendId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? "";

    if (userId.isNotEmpty) {
      await userProvider.acceptFriend(userId: userId, friendId: friendId);
      setState(() {
        _message = userProvider.statusMessage ?? "Friend request accepted!";
      });
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Share Location and Manage Friends'),
      actions: [
        IconButton(
          icon: Image.asset('assets/images/request.png'),
          onPressed: () {
            // Check for friend requests and display the dialog
            _showFriendRequestDialog();
          },
        ),
        IconButton(
          icon: Icon(Icons.group),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendsListScreen(friends: _friends),
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
            Expanded(child: _buildUsernamesList()), // Display usernames
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
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
void _showFriendRequestDialog() {
  if (_friends.isNotEmpty) {
    // Show the first pending friend request, or an empty map if none are found
    final friendRequest = _friends.firstWhere(
      (friend) => friend['status'] == 'pending',
      orElse: () => {}, // Return an empty map instead of null
    );

    // Check if the returned map is not empty, indicating a pending request was found
    if (friendRequest.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => FriendRequestDialog(
          friendId: friendRequest['id'],
          onAccept: (friendId) {
            _acceptFriend(friendId); // Handle the acceptance of the friend request
          },
        ),
      );
    } else {
      setState(() {
        _message = "No pending friend requests.";
      });
    }
  } else {
    setState(() {
      _message = "No friend requests available.";
    });
  }
}

  Widget _buildUsernamesList() {
    return ListView.builder(
      itemCount: _usernames.length,
      itemBuilder: (context, index) {
        final user = _usernames[index];
        final userId = user['id'];
        final username = user['username'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/default-profile.png'),
          ),
          title: Text(username),
          trailing: IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final currentUserId = userProvider.userId ?? "";

              if (userId != currentUserId) {
                await userProvider.addFriend(userId: currentUserId, friendId: userId);
                setState(() {
                  _message = "User added successfully!";
                });
              } else {
                setState(() {
                  _message = "Cannot add yourself as a friend.";
                });
              }
            },
          ),
        );
      },
    );
  }
}


class FriendsListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> friends;

  FriendsListScreen({required this.friends});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final friendId = friend['id'];
          final username = friend['username'];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/default-profile.png'),
            ),
            title: Text(username),
          );
        },
      ),
    );
  }
}

 // Fetch usernames from the provider Future
 //<void> _fetchUsernames() async { final userProvider = Provider.of<UserProvider>(context, listen: false); final userId = userProvider.userId; if (userId != null && userId.isNotEmpty) { await userProvider.fetchAllUsernames(userId); // Fetch all usernames // Ensure that userProvider.usernames is a list of maps if (userProvider.usernames is List<Map<String, dynamic>>) { setState(() { _usernames = List<Map<String, dynamic>>.from(userProvider.usernames); // Store usernames }); } else { // Handle unexpected format print('Error: Usernames are not in the expected format'); setState(() { _usernames = []; // Clear the list or handle as necessary }); } // Print the fetched usernames for debugging print('Fetched usernames: $_usernames'); } else { print('User ID is null or empty'); } } 
class FriendRequestDialog extends StatelessWidget {
  final String friendId;
  final Function(String) onAccept;

  FriendRequestDialog({required this.friendId, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Accept Friend Request'),
      content: Text('Do you want to accept the friend request from this user?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onAccept(friendId);
            Navigator.of(context).pop();
          },
          child: Text('Accept'),
        ),
      ],
    );
  }
}
