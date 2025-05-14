import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';

class AssignVehicleScreen extends StatefulWidget {
  @override
  _AssignVehicleScreenState createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  int? selectedDriverId;
  String? selectedVehicle;
  int? selectedVehicleId;

  List<Map<String, dynamic>> drivers = [];
  List<Map<String, dynamic>> vehicles = [];

  bool isLoadingDrivers = true;
  bool isLoadingVehicles = true;



  @override
  void initState() {
    super.initState();
    fetchDrivers();
    fetchVehicles();
  }

  Future<void> fetchDrivers() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetActiveDrivers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          drivers = data.map((driver) => {
            'driverId': driver['driverId'],
            'name': '${driver['fullName']} (${driver['employeeId']})',
          }).toList();
          isLoadingDrivers = false;
        });
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      setState(() {
        isLoadingDrivers = false;
      });
    }
  }

  Future<void> fetchVehicles() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/VehicleAll');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vehicles = data.map((vehicle) => {
            'vehicleId': vehicle['vehicleId'],
            'displayText': '${vehicle['modelName']} - ${vehicle['numberPlate']}',
          }).toList();
          isLoadingVehicles = false;
        });
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        isLoadingVehicles = false;
      });
    }
  }
  Future<void> assignVehicle() async {
    if (selectedDriverId == null || selectedVehicleId == null) return;

    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Admin/AddDriverVehicleMap?DriverId=$selectedDriverId&VehicleId=$selectedVehicleId');

    try {
      final response = await http.post(url);
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vehicle assigned successfully!'),
          backgroundColor: AppColors.primaryColor,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Assignment failed!'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print('Error assigning vehicle: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong!'),
        backgroundColor: Colors.red,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assign Vehicle to Driver',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assign Vehicle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                isLoadingDrivers
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Driver',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDriverId,
                  items: drivers.map((driver) {
                    return DropdownMenuItem<int>(
                      value: driver['driverId'],
                      child: Text(driver['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDriverId = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                isLoadingVehicles
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Vehicle',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedVehicleId,
                  items: vehicles.map((vehicle) {
                    return DropdownMenuItem<int>(
                      value: vehicle['vehicleId'],
                      child: Text(vehicle['displayText']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleId = value;
                    });
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (selectedDriverId != null && selectedVehicleId != null) {
                      assignVehicle();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please select both driver and vehicle'),
                        backgroundColor: AppColors.primaryColor2,
                      ));
                    }
                  },
                  icon: Icon(Icons.send, color: AppColors.primaryColor),
                  label: Text(
                    'Assign Vehicle',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}