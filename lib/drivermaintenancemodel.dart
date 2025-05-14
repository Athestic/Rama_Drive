class Maintenance {
  final String createdOn;
  final String vehicleImage;
  final String numberPlate;
  final String fullName;
  final String maintenancType;
  final double serviceCost;
  final String modelName; // <-- new field

  Maintenance({
    required this.createdOn,
    required this.vehicleImage,
    required this.numberPlate,
    required this.fullName,
    required this.maintenancType,
    required this.serviceCost,
    required this.modelName, // <-- include here
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      createdOn: json['createdOn'] ?? '',
      vehicleImage: json['vehicleImage'] ?? '',
      numberPlate: json['numberPlate'] ?? '',
      fullName: json['fullName'] ?? '',
      maintenancType: json['maintenancType'] ?? '',
      serviceCost: (json['serviceCost'] as num).toDouble(),
      modelName: json['modelName'] ?? '', // <-- parse here
    );
  }
}
