import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'colors.dart';
import 'adminlogin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonDisabled = false;

  Future<void> sendOtp() async {
    setState(() => _isButtonDisabled = true);
    final String phoneNumber = _phoneController.text.trim();
    final String apiUrl = "http://192.168.1.110:8081/api/Driver/Login?PhoneNo=$phoneNumber";

    try {
      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('encryptedOtp') && responseData.containsKey('token')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneNumber,
                encryptedOtp: responseData['encryptedOtp'],
              ),
            ),
          );
        } else {
          showError("OTP or token not received.");
        }
      } else {
        showError("Please enter correct mobile number.");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => _isButtonDisabled = false);
    }
  }

  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_token') != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF54c8be), Color(0xFF065a54)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RamaDrive',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Manage your vehicle',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Text(
                            '+91',
                            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.black87),
                          ),
                        ),
                        hintText: 'Enter Your Number',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        onPressed: _isButtonDisabled ? null : sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isButtonDisabled
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Login', style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white,fontFamily: 'Poppins'),),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.8,
                        height: screenWidth * 0.2,
                        child: Stack(
                          children: [
                            // Red Line Positioned Correctly
                            Positioned(
                              top: screenWidth * 0.12, // Adjust height to align below images
                              left: screenWidth * 0.13,
                              right: screenWidth *0.18,// Start the line from the front of the car
                              child: Container(
                                height: 2, // Thin line
                                width: screenWidth * 0.55,
                                color: Colors.red, // Line color
                              ),
                            ),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end, // Align images at bottom
                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Image.asset('assets/car.png', width: screenWidth * 0.15),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Image.asset('assets/hospital.png', width: screenWidth * 0.2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
