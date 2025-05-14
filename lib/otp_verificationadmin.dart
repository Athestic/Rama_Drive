import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'homeadmin.dart';
import 'colors.dart';
import 'package:lottie/lottie.dart';

class OtpVerificationadminScreen extends StatefulWidget {
  final String otp;
  OtpVerificationadminScreen(this.otp);

  @override
  _OtpVerificationadminScreenState createState() =>
      _OtpVerificationadminScreenState();
}

class _OtpVerificationadminScreenState
    extends State<OtpVerificationadminScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _secondsRemaining = 120;
  bool _isResendEnabled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
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

  void verifyOtp() async{
    if (_otpController.text.trim() == widget.otp) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageAdmin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid OTP!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void resendOtp() {
    if (!_isResendEnabled) return;
    setState(() {
      _isResendEnabled = false;
    });
    _timer?.cancel();
    startTimer();

    // TODO: API call for resend OTP
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Back', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Title
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Rama",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
                  ),
                  TextSpan(
                    text: "Drive",
                    style: TextStyle(fontSize: 25, color: AppColors.secondaryColor),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
            Text(
              "OTP Verification",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Enter the verification code sent to your number",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: screenWidth * 0.12,
                      height: 50,
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.grey.shade100,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  _secondsRemaining > 0
                      ? "0${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
                      : "",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),

            SizedBox(height: 20),

            GestureDetector(
              onTap: _isResendEnabled ? resendOtp : null,
              child: RichText(
                text: TextSpan(
                  text: "Didn’t receive the code? ",
                  style: TextStyle(fontSize: 16, color: Colors.black),
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

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Verify",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Albert_Sans'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
