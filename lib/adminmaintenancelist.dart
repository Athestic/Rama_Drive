import 'package:flutter/material.dart';
import 'package:ramadrive/MaintenanceEntry.dart';
import 'package:intl/intl.dart'; // Add intl in pubspec.yaml
import 'colors.dart';

class MaintenanceListScreen extends StatelessWidget {
  final List<MaintenanceEntry> maintenanceList;

  const MaintenanceListScreen({Key? key, required this.maintenanceList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get today's date in 'yyyy-MM-dd' format
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Filter list for only today's entries
    final todayMaintenanceList = maintenanceList.where((entry) {
      final entryDate = entry.createdOn?.split("T").first;
      return entryDate == today;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Maintenance Logs",
            style: TextStyle(color: AppColors.primaryColor, fontSize: 18 , fontWeight: FontWeight.bold),),
        // backgroundColor: Colors.deepPurple,
      ),
      body: todayMaintenanceList.isEmpty
          ? Center(child: Text('No maintenance logs for today.'))
          : ListView.builder(
        itemCount: todayMaintenanceList.length,
        itemBuilder: (context, index) {
          final entry = todayMaintenanceList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Driver Name: ${entry.fullName}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Vehicle Number : ${entry.numberPlate}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Vehicle ID: ${entry.vehicleId}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    // SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Text("Driver ID: ${entry.driverId}", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    // SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Service Cost: ₹${entry.serviceCost}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    // SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.comment,color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.remark ?? '',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primaryColor, size: 18),
                        SizedBox(width: 4),
                        Text(
                          entry.createdOn?.split("T").first ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
