import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'dart:async';
import 'ramaemployee.dart';
import 'colors.dart';
import 'upload_document.dart';
import 'package:ramadrive/Add_Driver.dart';
import 'vehicle_screen.dart';
import 'package:lottie/lottie.dart';

class user_verificationScreen extends StatefulWidget {
  final String phoneNumber;
  String encryptedOtp;
  final String employeeCode;


  user_verificationScreen({
    required this.phoneNumber,
    required this.encryptedOtp,
    required this.employeeCode,

  });

  @override
  _user_verificationScreenState createState() => _user_verificationScreenState();
}

class _user_verificationScreenState extends State<user_verificationScreen> {
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
    print(widget.employeeCode);
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
      // Show loading animation
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
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text("Verifying...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      );

      // Ensure the dialog is displayed for at least 2 seconds
      await Future.delayed(Duration(seconds: 2));

      if (widget.employeeCode.isNotEmpty) {
        try {
          String apiUrl = "http://192.168.1.110:8081/api/Driver/AddDriver?empcode=${widget.employeeCode}";
          var response = await http.post(Uri.parse(apiUrl));

          Navigator.pop(context); // Close loading dialog

          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            int driverId = responseData['driverId']; // ✅ Get the dynamic driverId

            // ✅ Navigate dynamically with driverId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UploadIdentityScreen(driverId: driverId)),
            );

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to add driver: ${response.body}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.pop(context); // Close animation

        // 🔹 If employeeCode is empty, go to AddDriverScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddDriverScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP"), backgroundColor: Colors.red),
      );
    }
  }

  void startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    _isResendEnabled = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
          const SnackBar(content: Text("Failed to resend OTP"), backgroundColor: Colors.red),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Center(
          child: Text(
            "RamaDrive",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("OTP Verification", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("OTP has been sent to +91 ${widget.phoneNumber}", style: const TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Pinput(
                    controller: otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: 50,
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
                Text(
                  _secondsRemaining > 0 ? "0${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}" : "",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isResendEnabled ? resendOtp : null,
              child: Text("Resend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isResendEnabled ? AppColors.primaryColor : Colors.grey)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Verify", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
