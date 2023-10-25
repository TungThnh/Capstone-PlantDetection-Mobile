
class HDUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  String? classStatus;
  final String college;
  final String? phone;
  final String? address;
  final String? dayOfBirth;
  final String status;


  HDUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.classStatus,
    required this.college,
    this.phone,
    this.address,
    this.dayOfBirth,
    required this.status,
  });

  factory HDUserModel.fromJson(Map<String, dynamic> json) {
    return HDUserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      college: json['college'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      dayOfBirth: json['dayOfBirth'] ?? '',
      status: json['status'] ?? '',
    );
  }
}