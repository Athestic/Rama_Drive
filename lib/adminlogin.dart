import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
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
    final String apiUrl = "http://192.168.1.110:8081/api/Admin/AdminLogin?Username=$username&Password=$password";



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
              builder: (context) => OtpVerificationScreen(decryptedOtp),
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
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decrypt64(encryptedOtp, iv: iv);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double paddingHorizontal = size.width * 0.08;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF54c8be), Color(0xFF065a54)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>LoginScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: size.width * 0.06),
                    SizedBox(width: 8),
                    Text('Back', style: TextStyle(fontSize: size.width * 0.045, color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'RamaDrive',
                style: TextStyle(
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor2,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter Username',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.person, color: Colors.black87),
                ),
              ),
              SizedBox(height: size.height * 0.025),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.lock, color: Colors.black87),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black87),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.025),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: AppColors.primaryColor2,
                    onChanged: (bool? value) => setState(() => _isChecked = value!),
                  ),
                  Text(
                    'I agree to the Terms & Conditions',
                    style: TextStyle(fontSize: size.width * 0.035, color: Colors.white),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _isButtonDisabled ? null : adminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

