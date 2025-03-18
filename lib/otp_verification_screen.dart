import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  String encryptedOtp;

  OtpVerificationScreen({required this.phoneNumber, required this.encryptedOtp});

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

  void verifyOtp() {
    String decryptedOtp = decryptOtp(widget.encryptedOtp);
    String userEnteredOtp = otpController.text.trim();

    if (decryptedOtp == userEnteredOtp) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
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

    String url = "http://192.168.1.110:8081/api/Driver/Login?PhoneNo=${widget.phoneNumber}";

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          widget.encryptedOtp = data["encryptedOtp"];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"]), backgroundColor: Colors.blue),
        );
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      "OTP Verification",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "OTP has been sent to +91 ${widget.phoneNumber}",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Pinput(
                      controller: otpController,
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
                    Column(
                      children: [
                        if (!_isResendEnabled)
                          Text(
                            "Resend  in $_secondsRemaining seconds",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          )
                        else
                          GestureDetector(
                            onTap: resendOtp,
                            child: Text(
                              "Resend",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),

                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          "Verify",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
