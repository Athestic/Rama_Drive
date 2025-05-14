class AssignedTrip {
  final int tripId;
  final int driverId;
  final String driverName;
  final String vehicleNumber;
  final String assignDate;

  AssignedTrip({
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.vehicleNumber,
    required this.assignDate,
  });

  factory AssignedTrip.fromJson(Map<String, dynamic> json) {
    return AssignedTrip(
      tripId: json['tripId'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      vehicleNumber: json['vehicleNumber'],
      assignDate: json['assignDate'],
    );
  }
}
