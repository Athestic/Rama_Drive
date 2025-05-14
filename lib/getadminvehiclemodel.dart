class Vehicle {
  final int vehicleId; // corrected from vehiclesId
  final String registrationNumber;
  final String modelYear;
  final String? vehicleImage;
  final String numberPlate;
  final int? fuelCapacity;

  Vehicle({
    required this.vehicleId,
    required this.registrationNumber,
    required this.modelYear,
    this.vehicleImage,
    required this.numberPlate,
    this.fuelCapacity,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'], // updated key
      registrationNumber: json['registrationNumber'],
      modelYear: json['modelYear'],
      vehicleImage: json['vehicleImage'],
      numberPlate: json['numberPlate'],
      fuelCapacity: json['fuelCapacity'],
    );
  }
}
