import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'fuel_entry.dart';
import 'colors.dart';
class FuelListScreen extends StatefulWidget {
  const FuelListScreen({Key? key}) : super(key: key);

  @override
  _FuelListScreenState createState() => _FuelListScreenState();
}

class _FuelListScreenState extends State<FuelListScreen> {
  late Future<List<FuelEntry>> futureFuelList;

  @override
  void initState() {
    super.initState();
    futureFuelList = fetchFuelEntries();
  }

  Future<List<FuelEntry>> fetchFuelEntries() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayFuelDetails'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'];

      // Get today's date as string in yyyy-MM-dd format
      final today = DateTime.now();
      final todayString = "${today.year.toString().padLeft(4, '0')}-${today
          .month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(
          2, '0')}";

      // Filter only today's entries
      final todayList = list.where((e) {
        final createdOn = e['createdOn'] as String?;
        return createdOn != null && createdOn.startsWith(todayString);
      }).toList();

      return todayList.map((e) => FuelEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load fuel entries');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Entries',
          style: TextStyle(color: AppColors.primaryColor, fontSize: 18 , fontWeight: FontWeight.bold),),

      ),
      body: FutureBuilder<List<FuelEntry>>(
        future: futureFuelList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No fuel entries found."));
          } else {
            final fuelList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fuelList.length,
              itemBuilder: (context, index) {
                final fuel = fuelList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                                Icons.local_gas_station, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              "${fuel.fuelQuantity} Litres",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "₹${fuel.fuelPrice}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                                Icons.speed, size: 20, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              "Meter Reading: ${fuel.meterReading}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20,
                                color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              "Date: ${fuel.createdOn
                                  .split('T')
                                  .first}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}