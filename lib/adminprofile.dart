import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'adminprofilemodel.dart';
import 'colors.dart';

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  List<AdminProfileModel> admins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('admin_userId');

    if (storedUserId != null) {
      print('✅ Retrieved admin_userId: $storedUserId');

      final response = await http.get(
        Uri.parse(
            'http://192.168.1.110:8081/api/Admin/GetActiveAdmins?UserId=$storedUserId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'] as List;
        setState(() {
          admins = jsonData.map((admin) => AdminProfileModel.fromJson(admin))
              .toList();
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch admin data. Status Code: ${response
            .statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("❌ No admin_userId found in SharedPreferences.");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Profile",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryColor),
      ),
      body: Container(
        color: Colors.grey[100],
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : admins.isEmpty
            ? Center(child: Text("No admin data found."))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.indigo[100],
                    backgroundImage: admins[0].adminImage != null
                        ? NetworkImage(admins[0].adminImage!)
                        : null,
                    child: admins[0].adminImage == null
                        ? Text(
                      admins[0].name.isNotEmpty
                          ? admins[0].name[0]
                          : '?',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.indigo,
                      ),
                    )
                        : null,
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow("Name", admins[0].name),
                  _buildInfoRow("Username", admins[0].userName),
                  _buildInfoRow("Email", admins[0].email),
                  _buildInfoRow("Mobile", admins[0].mobileNumber),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}