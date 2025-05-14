import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  VehicleDetailsScreen({required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                "http://192.168.1.110:8081${vehicleData["vehicleImage"]}",
                height: 200,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, size: 200, color: Colors.teal),
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow("Number Plate", vehicleData["numberPlate"]),
            _buildDetailRow("Model Name", vehicleData["modelName"]),
            _buildDetailRow("Manufacturer", vehicleData["vM_Name"]),
            _buildDetailRow("Model Year", vehicleData["modelYear"]),
            _buildDetailRow("Engine Type", vehicleData["engineType"]),
            _buildDetailRow("Category", vehicleData["categoryName"]),
            _buildDetailRow("Initial Reading", "${vehicleData["initialReading"]} km"),
            _buildDetailRow("Final Reading", "${vehicleData["finalReading"]} km"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value ?? "N/A", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
