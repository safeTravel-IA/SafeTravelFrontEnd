import 'package:flutter/material.dart';
import 'package:safetravelfrontend/pages/currency_convertor.dart';
import 'package:safetravelfrontend/pages/destinations_list.dart';
import 'package:safetravelfrontend/pages/forum.dart';
import 'package:safetravelfrontend/pages/local_contacts.dart';
import 'package:safetravelfrontend/pages/map_screen.dart';
import 'package:safetravelfrontend/pages/share_location.dart';
import 'package:safetravelfrontend/pages/translation_screen.dart';
import 'package:safetravelfrontend/pages/weather_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'top_appbar.dart';
import 'custom_bottom_navigation_bar.dart'; // Ensure this import is correct

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    // Initialize or fetch necessary data here if needed
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _showLogoutConfirmationDialog() {
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
                _logout();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // You can add your actual pages here when you're ready
  final List<Widget> _pages = [
    MapScreen(),
    Forum(), // Add your third page here
    LocalContacts(), // Add your third page here
    ShareLocationScreen(), // Add your third page here
    CurrencyConverter(),
    TranslationScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'SafeTravel',
        onLogout: _showLogoutConfirmationDialog,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
