class DriverTrip {
  final String driverName;
  final String vehicleNumber;
  final String tripStatus;

  DriverTrip({
    required this.driverName,
    required this.vehicleNumber,
    required this.tripStatus,
  });

  factory DriverTrip.fromJson(Map<String, dynamic> json) {
    return DriverTrip(
      driverName: json['driverName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      tripStatus: json['tripStatus'] ?? '',
    );
  }
}
