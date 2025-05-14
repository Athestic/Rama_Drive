class FuelLog {
  final int fuelId;
  final String fullName;
  final int vehiclesId;
  final double fuelPrice;
  final double meterReading;
  final double fuelQuantity;
  final String fuelLongitude;
  final String fuelLatitude;
  final String? receiptImage;
  final String createdOn;
  final String numberPlate;
  final String? vehicleImage;

  FuelLog({
    required this.fuelId,
    required this.fullName,
    required this.vehiclesId,
    required this.fuelPrice,
    required this.meterReading,
    required this.fuelQuantity,
    required this.fuelLongitude,
    required this.fuelLatitude,
    this.receiptImage,
    required this.createdOn,
    required this.numberPlate,
    this.vehicleImage,
  });

  factory FuelLog.fromJson(Map<String, dynamic> json) {
    return FuelLog(
      fuelId: json['fuelId'],
      fullName: json['fullName'],
      vehiclesId: json['vehiclesId'],
      fuelPrice: json['fuelPrice'],
      meterReading: json['meterReading'],
      fuelQuantity: json['fuelQuantity'],
      fuelLongitude: json['fuelLongitude'],
      fuelLatitude: json['fuelLatitude'],
      receiptImage: json['receiptImage'],
      createdOn: json['createdOn'],
      numberPlate: json['numberPlate'],
      vehicleImage: json['vehicleImage'],
    );
  }
}
