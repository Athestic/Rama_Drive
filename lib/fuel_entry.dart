class FuelEntry {
  final int fuelId;
  final int driverId;
  final int vehiclesId;
  final double fuelPrice;
  final double meterReading;
  final double fuelQuantity;
  final String fuelLongitude;
  final String fuelLatitude;
  final String receiptImage;
  final String createdOn;

  FuelEntry({
    required this.fuelId,
    required this.driverId,
    required this.vehiclesId,
    required this.fuelPrice,
    required this.meterReading,
    required this.fuelQuantity,
    required this.fuelLongitude,
    required this.fuelLatitude,
    required this.receiptImage,
    required this.createdOn,
  });

  factory FuelEntry.fromJson(Map<String, dynamic> json) {
    return FuelEntry(
      fuelId: json['fuelId'] ?? 0,
      driverId: json['driverId'] ?? 0,
      vehiclesId: json['vehiclesId'] ?? 0,
      fuelPrice: (json['fuelPrice'] ?? 0).toDouble(),
      meterReading: (json['meterReading'] ?? 0).toDouble(),
      fuelQuantity: (json['fuelQuantity'] ?? 0).toDouble(),
      fuelLongitude: json['fuelLongitude'] ?? '',
      fuelLatitude: json['fuelLatitude'] ?? '',
      receiptImage: json['receiptImage'] ?? '',
      createdOn: json['createdOn'] ?? '',
    );
  }
}