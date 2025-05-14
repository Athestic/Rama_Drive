import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'login.dart';

class UploadIdentityScreen extends StatefulWidget {
  final int driverId;

  const UploadIdentityScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  _UploadIdentityScreenState createState() => _UploadIdentityScreenState();
}

class _UploadIdentityScreenState extends State<UploadIdentityScreen> {
  File? aadharImage;
  File? dlImage;

  Future<void> pickImage(bool isAadhar) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isAadhar) {
          aadharImage = File(pickedFile.path);
        } else {
          dlImage = File(pickedFile.path);
        }
      });
    }
  }

  void removeImage(bool isAadhar) {
    setState(() {
      if (isAadhar) {
        aadharImage = null;
      } else {
        dlImage = null;
      }
    });
  }

  Future<void> submitDocument() async {
    String apiUrl = "http://192.168.1.110:8081/api/Driver/AddDocument";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({"Content-Type": "multipart/form-data"});
      request.fields["DriverId"] = widget.driverId.toString();

      if (aadharImage != null) {
        request.files.add(await http.MultipartFile.fromPath('AdharImage', aadharImage!.path));
      }
      if (dlImage != null) {
        request.files.add(await http.MultipartFile.fromPath('DLImage', dlImage!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
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
                    const Text("Driver Added Succesfully...", style: TextStyle(fontSize: 16)),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload documents: ${response.body}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading documents: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "RAMA", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal)),
                TextSpan(text: "drive", style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal, color: Colors.teal)),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload Your\nIdentity Cards',
                      style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  if (aadharImage == null)
                    IdentityCard(
                      title: 'Upload Your',
                      subtitle: 'Aadhar Card Image',
                      imagePath: 'assets/aadhar.png',
                      onTap: () => pickImage(true),
                    ),
                  if (dlImage == null)
                    IdentityCard(
                      title: 'Add Your',
                      subtitle: 'Driving Licence Image',
                      imagePath: 'assets/dl.png',
                      onTap: () => pickImage(false),
                    ),

                  SizedBox(height: 30),

                  if (aadharImage != null || dlImage != null)
                    Column(
                      children: [
                        Divider(),
                        Text("Completed", style: TextStyle(fontSize: screenWidth * 0.045)),
                        SizedBox(height: 10),
                        if (aadharImage != null)
                          CompletedCard(title: "Aadhar Card", onRemove: () => removeImage(true)),
                        if (dlImage != null)
                          CompletedCard(title: "Driving Licence", onRemove: () => removeImage(false)),
                      ],
                    ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (aadharImage != null || dlImage != null) ? submitDocument : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (aadharImage != null || dlImage != null) ? Colors.teal : Colors.grey,
                      ),
                      child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045)),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class IdentityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  IdentityCard({required this.title, required this.subtitle, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black54)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
              ],
            ),
            Image.asset(imagePath, height: screenWidth * 0.2),
          ],
        ),
      ),
    );
  }
}

class CompletedCard extends StatelessWidget {
  final String title;
  final VoidCallback onRemove;

  CompletedCard({required this.title, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: onRemove),
        ],
      ),
    );
  }
}
