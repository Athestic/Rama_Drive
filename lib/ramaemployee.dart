import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'colors.dart';
import 'adminlogin.dart';
import 'login.dart';
import 'user_verification.dart';

class RamaemployeeScreen extends StatefulWidget {
  @override
  _RamaemployeeScreenState createState() => _RamaemployeeScreenState();
}

class _RamaemployeeScreenState extends State<RamaemployeeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isButtonDisabled = _phoneController.text.isEmpty;
      });
    });
  }

  Future<void> sendOtp() async {
    setState(() => _isButtonDisabled = true);
    final String phoneNumber = _phoneController.text.trim();
    final String apiUrl =
        "http://192.168.1.110:8081/api/Driver/OtpByPhoneNumber?MobileNumber=$phoneNumber";

    try {
      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('encryptedOtp') &&
            responseData.containsKey('token')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']);

          String employeeCode =
              responseData['employeeCode']?.toString() ?? ""; // Ensure it's always a string

          await prefs.setString('employee_code', employeeCode);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => user_verificationScreen(
                phoneNumber: phoneNumber,
                encryptedOtp: responseData['encryptedOtp'],
                employeeCode: employeeCode,
              ),
            ),
          );
        } else {
          showError("OTP or token not received.");
        }
      } else {
        showError("Incorrect Employee Code");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => _isButtonDisabled = _phoneController.text.isEmpty);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Rama",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
                TextSpan(
                  text: "Drive",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("Help Button Clicked");
            },
            child: Text(
              'Help',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 600;
            bool isDesktop = constraints.maxWidth > 1000;

            return Center(
              child: Container(
                width: isDesktop
                    ? 600
                    : double.infinity, // Center on desktop, full width otherwise
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40.0 : 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Create your\n",
                            style: TextStyle(
                              fontSize: isTablet ? 35 : 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: "Account",
                            style: TextStyle(
                              fontSize: isTablet ? 35 : 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      'Enter Number Associated with Emp ID.',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isButtonDisabled ? null : sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          minimumSize: Size(
                              screenWidth * (isTablet ? 0.6 : 0.9), 50),
                        ),
                        child: Text(
                          "Get OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 20 : 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
