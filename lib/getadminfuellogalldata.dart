import 'package:flutter/material.dart';
import 'getadminfuellogmodel.dart'; // Your model file
import 'colors.dart';
class FuelLogAllDataScreen extends StatelessWidget {
  final FuelLog fuelLog;
  final String baseUrl = "http://192.168.1.110:8081";

  const FuelLogAllDataScreen({Key? key, required this.fuelLog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Log Details',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: fuelLog.vehicleImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  baseUrl + fuelLog.vehicleImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.car_repair, size: 100),
            ),
            const SizedBox(height: 24),

            _buildDetailSection("Driver Name", fuelLog.fullName),
            _buildDetailSection("Number Plate", fuelLog.numberPlate),
            _buildDetailSection("Fuel Quantity", "${fuelLog.fuelQuantity} Ltr"),
            _buildDetailSection(
                "Fuel Price", "₹${fuelLog.fuelPrice.toStringAsFixed(2)}"),
            _buildDetailSection("Meter Reading", "${fuelLog.meterReading} Km"),
            _buildDetailSection("Fuel Latitude", fuelLog.fuelLatitude),
            _buildDetailSection("Fuel Longitude", fuelLog.fuelLongitude),
            _buildDetailSection("Date", fuelLog.createdOn.split("T")[0]),

            const SizedBox(height: 24),

            if (fuelLog.receiptImage != null) ...[
              Text(
                "Receipt Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  baseUrl + fuelLog.receiptImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14)),
          const Divider(thickness: 1, height: 20),
        ],
      ),
    );
  }
}