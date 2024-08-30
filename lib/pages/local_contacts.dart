import 'package:flutter/material.dart';

class LocalContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4EDEB), // Background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with time, network, etc.

            SizedBox(height: 16),
            Text(
              'Local Contacts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/search.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Please enter the hospital's or embassy's name, or contact the police.",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Hospital info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/hospital_image.png'),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOPITAL DE PNEUMO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Medical - surgical services.'),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16),
                        SizedBox(width: 4),
                        Text('V59H+W7H, Ariana'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Emergency, care, facilities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildServiceButton('assets/images/car.png', 'emergency'),
                _buildServiceButton('assets/images/love.png', 'care'),
                _buildServiceButton('assets/images/health.png', 'facilities'),
              ],
            ),
            Divider(height: 32, color: Colors.grey),
            // New results section
            Text(
              'New results',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            // Horizontal list of hospitals
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildHospitalCard('assets/images/hospital1.png', 'Preston Hospital lekki', 'Open 24 hours'),
                  _buildHospitalCard('assets/images/hospital2.png', 'Reddington Lekki Hospital', 'Opens 8am'),
                  _buildHospitalCard('assets/images/hospital3.png', 'Vedic Lifecare Hospital', 'Open 24 hours'),
                  // Add more hospital cards as needed
                ],
              ),
            ),
            // Call Police button
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/call.png',
                  width: 24,
                  height: 24,
                ),
                label: Text('Call Police'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFADD8E6), // light blue color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(String assetPath, String label) {
    return Column(
      children: [
        Image.asset(
          assetPath,
          width: 40,
          height: 40,
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildHospitalCard(String assetPath, String name, String status) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Image.asset(
            assetPath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            status,
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}


