class FuelLog {
  final int fuelId;
  final String numberPlate;
  final double fuelPrice;
  final double fuelQuantity;
  final double meterReading;
  final String? receiptImage;
  final String createdOn;
  final String engineType;

  FuelLog({
    required this.fuelId,
    required this.numberPlate,
    required this.fuelPrice,
    required this.fuelQuantity,
    required this.meterReading,
    this.receiptImage,
    required this.createdOn,
    required this.engineType,
  });

  factory FuelLog.fromJson(Map<String, dynamic> json) {
    return FuelLog(
      fuelId: json['fuelId'],
      numberPlate: json['numberPlate'],
      fuelPrice: json['fuelPrice'].toDouble(),
      fuelQuantity: json['fuelQuantity'].toDouble(),
      meterReading: json['meterReading'].toDouble(),
      receiptImage: json['receiptImage'],
      createdOn: json['createdOn'],
      engineType: json['engineType'],
    );
  }
}
