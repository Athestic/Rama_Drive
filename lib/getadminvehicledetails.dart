import 'package:flutter/material.dart';
import 'getadminvehiclemodel.dart';
import 'colors.dart';
class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({Key? key, required this.vehicle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Details",  style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Vehicle Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: vehicle.vehicleImage != null
                    ? Image.network(
                  'http://192.168.1.110:8081${vehicle.vehicleImage}',
                  height: 180,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  "assets/ScorpioClassic.png",
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle Info
            _buildDetailRow("Registration Number", vehicle.registrationNumber),
            const SizedBox(height: 12),
            _buildDetailRow("Model Year", vehicle.modelYear.toString()),
            const SizedBox(height: 12),
            _buildDetailRow("Number Plate", vehicle.numberPlate),
            const SizedBox(height: 12),
            _buildDetailRow(
                "Fuel Capacity", "${vehicle.fuelCapacity ?? 'N/A'} Litres"),
          ],
        ),
      ),
    );
  }

// Helper method for styled info rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}