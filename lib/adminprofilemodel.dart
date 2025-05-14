class AdminProfileModel {
  final int userId;
  final String name;
  final String mobileNumber;
  final String email;
  final String userName;
  final String? adminImage;

  AdminProfileModel({
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.userName,
    this.adminImage,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      userId: json['userId'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      userName: json['userName'],
      adminImage: json['adminImage'],
    );
  }
}
