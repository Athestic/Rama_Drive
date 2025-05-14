class Maintenance {
  final String fullName;
  final String modelName;
  final String maintenancType;
  final int serviceCost;
  final String remark;
  final String numberPlate;
  final String vehicleImage;
  final String createdOn;

  Maintenance({
    required this.fullName,
    required this.modelName,
    required this.maintenancType,
    required this.serviceCost,
    required this.remark,
    required this.numberPlate,
    required this.vehicleImage,
    required this.createdOn,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      fullName: json['fullName'],
      modelName: json['modelName'],
      maintenancType: json['maintenancType'],
      serviceCost: json['serviceCost'],
      remark: json['remark'],
      numberPlate: json['numberPlate'],
      vehicleImage: json['vehicleImage'] ?? '',
      createdOn: json['createdOn'],
    );
  }
}
