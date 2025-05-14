import 'package:flutter/material.dart';
import 'getadmaintenancemodel.dart';
import 'colors.dart';
import 'package:intl/intl.dart';
class GetMaintenanceAllDataScreen extends StatelessWidget {
  final Maintenance maintenance;

  GetMaintenanceAllDataScreen({required this.maintenance});

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Maintenance Details",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "http://192.168.1.110:8081${maintenance.vehicleImage}",
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 16),
                buildDetailRow("Vehicle Number", maintenance.numberPlate),
                buildDetailRow("Full Name", maintenance.fullName),
                buildDetailRow("Model", maintenance.modelName),
                buildDetailRow("Issue Type", maintenance.maintenancType),
                buildDetailRow("Service Cost", "₹${maintenance.serviceCost}"),
                buildDetailRow("Remarks", maintenance.remark ?? "No remarks"),
                buildDetailRow("Created On", formatDate(maintenance.createdOn)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}