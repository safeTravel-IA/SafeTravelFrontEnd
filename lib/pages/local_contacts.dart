import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:safetravelfrontend/providers/user_provider.dart';

class LocalContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider()..fetchAllHospitals(), // Initialize and fetch hospitals
      child: Scaffold(
        backgroundColor: Color(0xFFF4EDEB),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Local Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

      
              SizedBox(height: 16),
              // Display hospital info using Consumer
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final errorMessage = userProvider.errorMessage ?? '';

                  if (errorMessage.isNotEmpty) {
                    return Text(errorMessage, style: TextStyle(color: Colors.red));
                  }

                  if (userProvider.hospitals.isEmpty) {
                    return Center(child: CircularProgressIndicator()); // Show a loading indicator
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: userProvider.hospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = userProvider.hospitals[index];
                        return _buildHospitalCard(
                          hospital['imageUrl'] ?? 'assets/images/default_hospital.png', 
                          hospital['name'] ?? 'Unknown Hospital',
                          hospital['description'] ?? 'No description available',
                          hospital['contactNumber'] ?? '', // Pass contact number
                        );
                      },
                    ),
                  );
                },
              ),
              // Call Police button
              SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _callPolice(),
                  icon: Image.asset(
                    'assets/images/call.png',
                    width: 24,
                    height: 24,
                  ),
                  label: Text('Call Police'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFADD8E6),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard(String imageUrl, String name, String description, String contactNumber) {
    final baseUrl = 'http://10.0.2.2:3000/api/image/';
    String cleanedImage = imageUrl.startsWith('/uploads/')
        ? imageUrl.substring(9)  // Remove the "/uploads/" prefix
        : imageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(baseUrl + cleanedImage),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(description),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(contactNumber),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () => _makePhoneCall(contactNumber),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _callPolice() async {
    final policeNumber = '197';
    final url = 'tel:$policeNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
