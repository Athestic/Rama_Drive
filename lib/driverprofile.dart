import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';
class DriverProfileScreen extends StatefulWidget {
  final int driverId;
  const DriverProfileScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late Future<DriverProfile?> futureProfile;

  @override
  void initState() {
    super.initState();
    futureProfile = fetchDriverProfile(widget.driverId);
  }

  Future<DriverProfile?> fetchDriverProfile(int driverId) async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetActiveDriversByDriverId?DriverId=$driverId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        return DriverProfile.fromJson(data[0]);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Driver Profile",style: TextStyle(color: AppColors.primaryColor, fontSize: 18 , fontWeight: FontWeight.bold),),),
      body: FutureBuilder<DriverProfile?>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final profile = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    // color: Colors.blue.shade50,
                    child: Column(
                      children: [
                        // const CircleAvatar(
                        //   radius: 50,
                        //   backgroundImage: AssetImage('assets/avatar.png'), // use a default image
                        // ),
                        const SizedBox(height: 10),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(profile.mobileNumber,
                            style: const TextStyle(   fontSize: 20,color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Profile Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ProfileTile(
                          icon: Icons.badge,
                          title: 'Employee ID',
                          value: profile.employeeId,
                        ),
                        ProfileTile(
                          icon: Icons.home,
                          title: 'Permanent Address',
                          value: profile.permanentAddress ?? 'N/A',
                        ),
                        ProfileTile(
                          icon: Icons.location_city,
                          title: 'Current Address',
                          value: profile.address,
                        ),
                        ProfileTile(
                          icon: Icons.credit_card,
                          title: 'Aadhar Number',
                          value: profile.aadharNumber ?? 'N/A',
                        ),

                        ProfileTile(
                          icon: Icons.timeline,
                          title: 'Driving Experience',
                          value: profile.drivingExperience ?? 'N/A',
                        ),
                        ProfileTile(
                          icon: Icons.map,
                          title: 'State Name',
                          value: profile.stateName,
                        ),
                        ProfileTile(
                          icon: Icons.location_on,
                          title: 'Location',
                          value: profile.locationName ?? 'N/A',
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Center(child: Text('No profile found'));
          }
        },
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}

class DriverProfile {
  final int driverId;
  final String employeeId;
  final String fullName;
  final String mobileNumber;
  final String? permanentAddress;
  final String address;
  final String? aadharNumber; // 🔧 Changed to nullable
  final String? drivingExperience;
  final String stateName;
  final String? locationName;

  DriverProfile({
    required this.driverId,
    required this.employeeId,
    required this.fullName,
    required this.mobileNumber,
    this.permanentAddress,
    required this.address,
    this.aadharNumber, // 🔧 Changed to nullable
    this.drivingExperience,
    required this.stateName,
    this.locationName,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      driverId: json['driverId'],
      employeeId: json['employeeId'],
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      permanentAddress: json['permanentAddress'],
      address: json['address'],
      aadharNumber: json['aadharNumber'], // 🔧 no change here
      drivingExperience: json['drivingExperience'],
      stateName: json['stateName'],
      locationName: json['locationName'],
    );
  }
}
