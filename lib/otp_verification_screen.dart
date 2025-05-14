import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'dart:async';
import 'colors.dart';
import 'package:lottie/lottie.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  String encryptedOtp;
  final int driverId;

  OtpVerificationScreen({
    required this.phoneNumber,
    required this.encryptedOtp,
    required this.driverId,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  static const String encryptionKey = "12345678912345698745632165498712";
  static const String encryptionIV = "1234569874123659";
  int _secondsRemaining = 120;
  bool _isResendEnabled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    print(widget.driverId);
  }

  String decryptOtp(String encryptedOtp) {
    try {
      final key = encrypt.Key.fromUtf8(encryptionKey);
      final iv = encrypt.IV.fromUtf8(encryptionIV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedOtp, iv: iv);
      return decrypted;
    } catch (e) {
      return "Decryption failed";
    }
  }



  void verifyOtp() async {
    String decryptedOtp = decryptOtp(widget.encryptedOtp);
    String userEnteredOtp = otpController.text.trim();

    if (decryptedOtp == userEnteredOtp) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset(
                      'assets/Animation.json',
                      fit: BoxFit.cover,
                      animate: true,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.check_circle, size: 80, color: Colors.green);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Verifying...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      );

      await Future.delayed(Duration(seconds: 2));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', widget.encryptedOtp);
      await prefs.setInt('driverid', widget.driverId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(driverId: widget.driverId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP"), backgroundColor: Colors.red),
      );
    }
  }

  void startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    _isResendEnabled = false;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
          _timer?.cancel();
        });
      }
    });
  }

  Future<void> resendOtp() async {
    if (!_isResendEnabled) return;
    setState(() {
      _isResendEnabled = false;
    });
    _timer?.cancel();
    startTimer();
    String url = "http://192.168.1.110:8081/api/Driver/LoginByPhoneNumber?MobileNumber=${widget.phoneNumber}";
    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          widget.encryptedOtp = data["encryptedOtp"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to resend OTP"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/arrow_back.png',
                        width: 24,
                        height: 24,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text('Back', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Rama",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
                        ),
                        TextSpan(
                          text: "Drive",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal, color: AppColors.secondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "OTP Verification",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "OTP has been sent to +91 ${widget.phoneNumber}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Pinput(
                        controller: otpController,
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: screenWidth * 0.12,
                          height: 50,
                          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade100,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Countdown Timer
                    Text(
                      _secondsRemaining > 0
                          ? "0${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
                          : "",
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Resend Button
                GestureDetector(
                  onTap: _isResendEnabled ? resendOtp : null,
                  child: RichText(
                    text: TextSpan(
                      text: "Didn’t receive the code? ",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Resend",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isResendEnabled ? AppColors.primaryColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Verify",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Albert_Sans'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
