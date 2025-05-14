import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homeadmin.dart';
import 'colors.dart';
class PendingDriversScreen extends StatefulWidget {
  @override
  _PendingDriversScreenState createState() => _PendingDriversScreenState();
}

class _PendingDriversScreenState extends State<PendingDriversScreen> {
  List<dynamic> pendingDrivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingDrivers();
  }

  Future<void> fetchPendingDrivers() async {
    final url = Uri.parse(
        "http://192.168.1.110:8081/api/Driver/GetPendingDrivers");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          pendingDrivers = result["data"];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load pending drivers');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> activateDriver(int driverId) async {
    final url = Uri.parse(
        "http://192.168.1.110:8081/api/Admin/ActivateDriver?driverId=$driverId");

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        final message = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Driver activated successfully!')),
        );

        // Optionally refresh the list to remove the activated driver
        fetchPendingDrivers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activation failed. Try again.')),
        );
      }
    } catch (e) {
      print("Activation Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



  Widget buildDriverCard(Map<String, dynamic> driver) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'http://192.168.1.110:8081${driver["driverImage"] ?? ""}',
                ),
              ),
              title: Text(driver["fullName"] ?? "No Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(driver["employeeId"] ?? ""),
              trailing: ElevatedButton(
                onPressed: () => activateDriver(driver["driverId"]),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                child: Text("Activate",style: TextStyle(

                  fontWeight: FontWeight.normal,
                  color:Colors.white,
                ),),
              ),
            ),
            SizedBox(height: 8),
            infoRow("Mobile", driver["mobileNumber"]),
            infoRow("Email", driver["email"]),
            infoRow("Aadhar", driver["aadharNumber"]),
            infoRow("DL Number", driver["dlNumber"]),
            infoRow(
                "Driving Experience", "${driver["drivingExperience"]} years"),
            infoRow("Address", driver["permanentAddress"]),
            infoRow("Is Rama?", driver["isRama"] ? "Yes" : "No"),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value != null ? value.toString() : "N/A")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Drivers",
          style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),),
        centerTitle: true, // Center the title
        automaticallyImplyLeading: false,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pendingDrivers.isEmpty
          ? Center(child: Text("No pending drivers found."))
          : RefreshIndicator(
        onRefresh: fetchPendingDrivers,
        child: ListView.builder(
          itemCount: pendingDrivers.length,
          itemBuilder: (context, index) {
            return buildDriverCard(pendingDrivers[index]);
          },
        ),
      ),
    );
  }
}
