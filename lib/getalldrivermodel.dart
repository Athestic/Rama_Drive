class Driver {
  final int driverId;
  final String employeeId;
  final String fullName;
  final String mobileNumber;
  final String? address;
  final String? locationName;
  final String? stateName;
  final String? cityName;
  final String? driverImage;

  Driver({
    required this.driverId,
    required this.employeeId,
    required this.fullName,
    required this.mobileNumber,
    this.address,
    this.locationName,
    this.stateName,
    this.cityName,
    this.driverImage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'],
      employeeId: json['employeeId'],
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      locationName: json['locationName'],
      stateName: json['stateName'],
      cityName: json['cityName'],
      driverImage: json['driverImage'],
    );
  }
}
