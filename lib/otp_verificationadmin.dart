import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'homeadmin.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String otp;
  OtpVerificationScreen(this.otp);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
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

  void verifyOtp() {
    if (_otpController.text == widget.otp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageAdmin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP!"), backgroundColor: Colors.red),
      );
    }
  }

  void resendOtp() {
    setState(() {
      _secondsRemaining = 120;
      _isResendEnabled = false;
    });
    startTimer();
    // TODO: Call API to resend OTP
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B9B8F), Color(0xFF184D47)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            SizedBox(height: 40),
            Text(
              "Verify your new account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Enter the verification code sent to your number",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Pinput(
              controller: _otpController,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Colors.white54,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _secondsRemaining > 0
                    ? "0${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
                    : "",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _isResendEnabled ? resendOtp : null,
                child: Text(
                  "Didn’t receive the code? Resend",
                  style: TextStyle(
                    color: _isResendEnabled ? Colors.red : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
