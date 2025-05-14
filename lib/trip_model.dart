// trip_model.dart
class Trip {
  final int locationTripId;
  final String initialReading;
  final String finalReading;
  final String pickCity;
  final String dropCity;
  final DateTime startTime;
  final DateTime dropTime;

  Trip({
    required this.locationTripId,
    required this.initialReading,
    required this.finalReading,
    required this.pickCity,
    required this.dropCity,
    required this.startTime,
    required this.dropTime,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      locationTripId: json['locationTripId'],
      initialReading: json['initialReading'],
      finalReading: json['finalReading'],
      pickCity: json['pickCity'],
      dropCity: json['dropCity'],
      startTime: DateTime.parse(json['startTime']),
      dropTime: DateTime.parse(json['dropTime']),
    );
  }
}
