import 'package:flutter/material.dart';
import 'package:ramadrive/colors.dart';
import 'package:ramadrive/login.dart';
import 'home.dart';


class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isLoggedIn ? HomePage() : LoginScreen(),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor1,
      body: Column(
        children: <Widget>[
          Spacer(flex: 4),
          Center(
            child: Image.asset(
              'assets/rama.png',
              width: 400,
              height: 500,
            ),
          ),
          Spacer(flex: 3), // Pushes the text to the bottom
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text(
          //     'Rcs Global Pvt. Ltd.',
          //     style: TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
