import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'colors.dart';
import 'otp_verificationadmin.dart';
import 'homeadmin.dart';
import 'login.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonDisabled = false;
  bool _obscurePassword = true;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('admin_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageAdmin()),
      );
    }
  }

  Future<void> adminLogin() async {
    if (!_isChecked) {
      showError("Please agree to the terms & conditions.");
      return;
    }

    setState(() => _isButtonDisabled = true);

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String apiUrl =
        "http://192.168.1.110:8081/api/Admin/AdminLogin?Username=$username&Password=$password";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Username': username, 'Password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('token') &&
            responseData.containsKey('encryptedOtp') &&
            responseData.containsKey('userId')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', responseData['token']);
          await prefs.setInt('admin_userId', responseData['userId']);

          String decryptedOtp = decryptOtp(responseData['encryptedOtp']);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationadminScreen(decryptedOtp),
            ),
          );
        } else {
          showError("Invalid response. Please try again.");
        }
      } else {
        showError("Login failed. Please check your credentials.");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => _isButtonDisabled = false);
    }
  }

  String decryptOtp(String encryptedOtp) {
    final key = encrypt.Key.fromUtf8("12345678912345698745632165498712");
    final iv = encrypt.IV.fromUtf8("1234569874123659");
    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decrypt64(encryptedOtp, iv: iv);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final isTablet = screenWidth > 500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
        ),
        title: RichText(
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
        centerTitle: true,

      ),
      body: _buildLoginForm(screenWidth, screenHeight, isTablet: isTablet),
    );
  }

  Widget _buildLoginForm(double screenWidth, double screenHeight,
      {bool isTablet = false}) {
    double horizontalPadding = isTablet ? 32 : 20;
    double titleFontSize = isTablet ? 36 : 30;
    double inputFontSize = screenWidth < 400 ? 14 : 16;
    double spacing = screenHeight * 0.02;

    return Container(
      color: Colors.white,
      width: double.infinity,
      height: screenHeight, // Ensure full height to avoid overflow
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Login into your\nAccount",
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
              fontFamily: 'Albert_Sans',
            ),
          ),
          SizedBox(height: spacing),
          Text(
            'Use admin credentials to proceed.',
            style: TextStyle(fontSize: inputFontSize, color: Colors.black),
          ),
          SizedBox(height: spacing),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Enter Username',
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: spacing),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                activeColor: AppColors.primaryColor2,
                onChanged: (bool? value) =>
                    setState(() => _isChecked = value!),
              ),
              Expanded(
                child: Text(
                  'I agree to the Terms & Conditions',
                  style: TextStyle(fontSize: inputFontSize),
                ),
              ),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _isButtonDisabled ? null : adminLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text("Continue",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

}