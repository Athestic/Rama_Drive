import 'package:flutter/material.dart';

class FuelLogScreen extends StatelessWidget {
  final List<dynamic> fuelLogs;

  FuelLogScreen({required this.fuelLogs});

  String _formatDate(String date) {
    // Assuming `date` is in ISO format
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fuel Log History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),),

      ),
      body: fuelLogs.isEmpty
          ? Center(child: Text("No fuel logs available"))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: fuelLogs.length,
        itemBuilder: (context, index) {
          var log = fuelLogs[index];

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
                      Text(
                        _formatDate(log["createdOn"]),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${log["fuelQuantity"]} Ltr",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    log["engineType"],
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      log["numberPlate"],
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade800,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "₹${log["fuelPrice"]}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
