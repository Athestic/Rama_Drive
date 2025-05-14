import 'package:flutter/material.dart';
import 'colors.dart';
class VehiclesOnRoadScreen extends StatelessWidget {
  final List<dynamic> vehicleData;

  VehiclesOnRoadScreen({required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicles On Road",
          style: TextStyle(color: AppColors.primaryColor, fontSize: 18 , fontWeight: FontWeight.bold),),

      ),
      body: ListView.builder(
        itemCount: vehicleData.length,
        itemBuilder: (context, index) {
          final vehicle = vehicleData[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color:AppColors.primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${vehicle['pickCity']} → ${vehicle['dropCity']}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start: ${vehicle['startTime'] != null ? vehicle['startTime'].split('T')[0] : 'N/A'}",
                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                          ),
                          Text(
                            "Time: ${vehicle['startTime'] != null ? vehicle['startTime'].split('T')[1].split('.')[0] : 'N/A'}",
                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Text(
                        "Driver ID: ${vehicle['driverId']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Spacer(),
                      Icon(Icons.directions_car, color:AppColors.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Vehicle ID: ${vehicle['vehiclesId']}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
