import 'package:flutter/material.dart';
import 'getalldrivermodel.dart';
import 'colors.dart';
class DriverDetailsScreen extends StatelessWidget {
  final Driver driver;

  const DriverDetailsScreen({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          driver.fullName,
             style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: driver.driverImage != null
                    ? NetworkImage(
                    'http://192.168.1.110:8081${driver.driverImage}')
                    : AssetImage("assets/Group.png") as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Name", driver.fullName),
                    _buildDetailRow("Mobile", driver.mobileNumber),
                    _buildDetailRow("Employee ID", driver.employeeId),
                    _buildDetailRow("Address", driver.address ?? 'N/A'),
                    _buildDetailRow("Location", driver.locationName ?? 'N/A'),
                    _buildDetailRow("State", driver.stateName ?? 'N/A'),
                    _buildDetailRow("City", driver.cityName ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
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