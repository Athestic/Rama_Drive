class MaintenanceEntry {
  final int maintenancId;
  final int vehicleId;
  final String fullName;
  final String modelName;
  final String maintenancType;
  final int driverId;
  final double serviceCost;
  final String remark;
  final String? serviceRecieptImage;
  final String? createdOn;
  final String numberPlate;
  final String vehicleImage;

  MaintenanceEntry({
    required this.maintenancId,
    required this.vehicleId,
    required this.fullName,
    required this.modelName,
    required this.maintenancType,
    required this.driverId,
    required this.serviceCost,
    required this.remark,
    this.serviceRecieptImage,
    this.createdOn,
    required this.numberPlate,
    required this.vehicleImage,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      maintenancId: json['maintenancId'],
      vehicleId: json['vehicleId'],
      fullName: json['fullName'] ?? '',
      modelName: json['modelName'] ?? '',
      maintenancType: json['maintenancType'] ?? '',
      driverId: json['createdBy'], // Assuming createdBy is driver ID
      serviceCost: (json['serviceCost'] as num).toDouble(),
      remark: json['remark'] ?? '',
      serviceRecieptImage: json['serviceRecieptImage'],
      createdOn: json['createdOn'],
      numberPlate: json['numberPlate'] ?? '',
      vehicleImage: json['vehicleImage'] ?? '',
    );
  }
}
