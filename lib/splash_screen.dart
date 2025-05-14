import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadrive/colors.dart';
import 'package:ramadrive/login.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  /// Check user session and navigate accordingly
  Future<void> _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? driverId = prefs.getInt('driverid');

    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds

    if (token != null && driverId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(driverId: driverId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double imageWidth = screenSize.width * 0.8;
    final double imageHeight = screenSize.height * 0.4;

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/ramadrive.png',
          width: imageWidth,
          height: imageHeight,
        ),
      ),
    );
  }
}
