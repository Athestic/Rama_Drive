import 'package:flutter/material.dart';
import 'colors.dart';
class AllMaintenanceHistoryScreen extends StatelessWidget {
  final List<dynamic> allRecords;

  AllMaintenanceHistoryScreen(this.allRecords);

  @override
  Widget build(BuildContext context) {
    final sortedRecords = allRecords.toList()
      ..sort((a, b) => DateTime.parse(b['createdOn']).compareTo(DateTime.parse(a['createdOn'])));

    return Scaffold(
      appBar: AppBar(title: Text("All Maintenance History",  style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),)),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: sortedRecords.length,
        itemBuilder: (context, index) {
          final item = sortedRecords[index];
          final date = DateTime.parse(item['createdOn']);
          final formattedDate = "${date.day}/${date.month}/${date.year}";
          final numberPlate = item['numberPlate'] ?? '';
          final serviceCost = item['serviceCost'];
          final type = item['maintenancType'] ?? '';
          final vehicleImage = item['vehicleImage'] != null
              ? "http://192.168.1.110:8081${item['vehicleImage']}"
              : "https://img.icons8.com/?size=100&id=7870&format=png";

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: TextStyle(color: Colors.grey[700])),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF7F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "₹$serviceCost",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade600,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(vehicleImage),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          numberPlate,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          type,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
