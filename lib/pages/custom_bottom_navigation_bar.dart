import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Add padding around the icon
          child: Image.asset('assets/images/explore.png', width: 24, height: 24), // Increase the icon size slightly
        ),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Image.asset('assets/images/community.png', width: 24, height: 24),
        ),
        label: 'Community',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Image.asset('assets/images/Emergency.png', width: 24, height: 24),
        ),
        label: 'Emergency',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Image.asset('assets/images/shared.png', width: 24, height: 24),
        ),
        label: 'Shared',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Image.asset('assets/images/convertor.png', width: 24, height: 24),
        ),
        label: 'Convertor',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Image.asset('assets/images/translator.png', width: 24, height: 24),
        ),
        label: 'Translator',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF4A4C52).withOpacity(0.8),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: items,
      selectedLabelStyle: const TextStyle(fontSize: 12), // Adjust the label size if needed
      unselectedLabelStyle: const TextStyle(fontSize: 10), // Smaller unselected label
    );
  }
}
