import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming you're using GetX for routing
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  File? _selectedImage; // State variable for storing the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final extension = file.path.split('.').last.toLowerCase();

      // Check if the file extension is jpg, jpeg, or png
      if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
        setState(() {
          _selectedImage = file;
        });
      } else {
        // Show an error message if the file type is not supported
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only JPG and PNG images are accepted.')),
        );
      }
    }
  }

  Future<void> _registerUser() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String firstName = firstNameController.text;
    final String lastName = lastNameController.text;
    final String phoneNumber = phoneNumberController.text;
    final String address = addressController.text;

    if (username.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || address.isEmpty) {
      print('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:3000/api/signup'); // Update with your API endpoint
      final request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['username'] = username;
      request.fields['password'] = password;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['address'] = address;

      // Add profile picture file if available
      if (_selectedImage != null) {
        final extension = _selectedImage!.path.split('.').last.toLowerCase();
        String mediaType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mediaType = 'image/jpeg';
            break;
          case 'png':
            mediaType = 'image/png';
            break;
          default:
            mediaType = 'image/jpeg'; // Fallback type
        }
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _selectedImage!.path,
          contentType: MediaType.parse(mediaType),
        ));
      }

      // Send the request
      final response = await request.send();

      // Parse the response
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful response
        Get.toNamed('/home');
      } else {
        // Handle error response
        print('Error: ${responseData['message']}');
      }
    } catch (e) {
      print('Failed to register user: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Onboard!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F61),
                    ),
                  ),
const SizedBox(height: 20),
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : AssetImage('assets/images/registerimage.png') as ImageProvider,
      ),
    ),
    const SizedBox(height: 10), // Space between the image and the icon
    GestureDetector(
      onTap: _pickImage,
      child: Icon(
        Icons.add_a_photo,
        size: 50,
        color: Colors.grey.shade800,
      ),
    ),
  ],
),


                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            hintText: 'First Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFBCDBDF),
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F61)),
                                )
                              : Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Color(0xFFFF6F61),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/login');
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: Color(0xFFFF6F61),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
