import 'package:get/get.dart';
import 'package:safetravelfrontend/pages/destination_plan.dart';
import 'package:safetravelfrontend/pages/launch_screen.dart';
import 'package:safetravelfrontend/pages/login_page.dart';
import 'package:safetravelfrontend/pages/signup_page.dart';
import 'package:safetravelfrontend/pages/home_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/splash', page: () => LaunchScreen()),
    GetPage(name: '/signup', page: () => SignupPage()),
    GetPage(name: '/signin', page: () => LoginPage()),
    GetPage(
      name: '/destinationPlanning',
      page: () {
        // Extract the 'destinationId' parameter from Get.parameters
        final String? destinationId = Get.parameters['_id'];
        return DestinationPlanning(destinationId: destinationId ?? '');
      },
      // You can optionally specify a transition or other options here
    ),
    GetPage(name: '/home', page: () => HomePage()),

    // Add other routes here
  ];
}
