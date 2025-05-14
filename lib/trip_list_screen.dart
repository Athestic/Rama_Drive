import 'package:flutter/material.dart';
import 'trip_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for date formatting
import 'colors.dart';

class TripListScreen extends StatelessWidget {
  Future<List<Trip>> fetchCompletedTrips() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetTripsComplete'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tripsJson = data['data'];

      DateTime today = DateTime.now();

      return tripsJson.map((json) => Trip.fromJson(json)).where((trip) {
        final dropDate = DateTime.tryParse(trip.dropTime?.toString() ?? '');
        return dropDate != null &&
            dropDate.year == today.year &&
            dropDate.month == today.month &&
            dropDate.day == today.day;
      }).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Trips',style: TextStyle(color: AppColors.primaryColor, fontSize: 18 , fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder<List<Trip>>(
        future: fetchCompletedTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading trips'));
          } else if (snapshot.hasData) {
            final trips = snapshot.data!;
            if (trips.isEmpty) {
              return Center(
                child: Text(
                  'No trips completed today.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_bus, color: AppColors.primaryColor),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${trip.pickCity} → ${trip.dropCity}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.play_arrow, size: 18, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Start: ${formatDateTime(trip.startTime)}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.stop, size: 18, color: Colors.red),
                            SizedBox(width: 6),
                            Text('End: ${formatDateTime(trip.dropTime)}'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Trip ID: ${trip.locationTripId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
