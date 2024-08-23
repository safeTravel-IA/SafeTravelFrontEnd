import 'package:get/get.dart';
import 'package:safetravelfrontend/pages/launch_screen.dart';
import 'package:safetravelfrontend/pages/login_page.dart';
import 'package:safetravelfrontend/pages/signup_page.dart';
import 'package:safetravelfrontend/pages/home_page.dart';
class AppPages {
  static final pages = [
    GetPage(name: '/splash', page: () => LaunchScreen()),
    GetPage(name: '/signup', page: () => SignupPage()),
    GetPage(name: '/signin', page: () => LoginPage()),

    GetPage(name: '/home', page: () => HomePage()),


    // Add other routes here
  ];
}