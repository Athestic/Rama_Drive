import 'package:flutter/material.dart';

class RecentTripScreen extends StatelessWidget {
  final List<dynamic> trips;

  RecentTripScreen({required this.trips});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Trips"),
        backgroundColor: Colors.teal.shade400,
      ),
      body: trips.isEmpty
          ? Center(child: Text("No recent trips available"))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          var trip = trips[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.black54,
                              size: screenWidth * 0.05),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            trip["startLocation"],
                            style: TextStyle(color: Colors.black87,
                                fontSize: screenWidth * 0.04),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          height: screenWidth * 0.005,
                          color: Colors.red,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            trip["endLocation"],
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: screenWidth * 0.04),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Icon(Icons.location_on, color: Colors.black54,
                              size: screenWidth * 0.05),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: screenWidth * 0.05,
                                color: Colors.teal),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              trip["date"],
                              style: TextStyle(color: Colors.teal,
                                  fontSize: screenWidth * 0.035),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.red.shade200,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: screenWidth * 0.05,
                                color: Colors.white),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              trip["time"],
                              style: TextStyle(color: Colors.white,
                                  fontSize: screenWidth * 0.035),
                            ),
                          ],
                        ),
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
