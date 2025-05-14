import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'colors.dart';
import 'adminlogin.dart';
import 'ramaemployee.dart';

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
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    // checkSession();
    _phoneController.addListener(() {
      setState(() {
        _isButtonDisabled = _phoneController.text.isEmpty;

      });
    });
  }

  Future<void> sendOtp() async {
    setState(() => _isButtonDisabled = true);
    final String phoneNumber = _phoneController.text.trim();
    final String apiUrl = "http://192.168.1.110:8081/api/Driver/LoginByPhoneNumber?MobileNumber=$phoneNumber";

    try {
      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('encryptedOtp') &&
            responseData.containsKey('token') &&
            responseData.containsKey('driverid')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          await prefs.setInt('driverid', responseData['driverid']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationScreen(
                    phoneNumber: phoneNumber,
                    encryptedOtp: responseData['encryptedOtp'],
                    driverId: responseData['driverid'],
                  ),
            ),
          );
        } else {
          showError("OTP, token, or driver ID not received.");
        }
      } else {
        showError("Please enter correct mobile number.");
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


  Widget _accountTypeCard(String title, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Image.asset(assetPath, width: 50, height: 50),
                SizedBox(height: 10),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
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
                                        fontSize: 30,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Log in to your\n",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.5,
                                      fontFamily: 'Albert_Sans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: "account",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Albert_Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Enter Number Associated with Emp ID.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12),
                                  child:
                                  Text("+91", style: TextStyle(fontSize: 16)),
                                ),
                                hintText: "Enter Your Number",
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Spacer(),
                            ElevatedButton(
                              onPressed: _isButtonDisabled ? null : sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                "Get OTP",
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Poppins'),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RamaemployeeScreen()),
                                );
                              },
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don’t have an account? ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Create Now",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                  );
                },
                icon: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Image.asset(
                    "assets/me.png",
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("Admin", style: TextStyle(color: Colors.white)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}