class HDManagerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? dayOfBirth;
  final String avatarUrl;
  final String status;

  HDManagerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.dayOfBirth,
    required this.avatarUrl,
    required this.status,
  });

  factory HDManagerModel.fromJson(Map<String, dynamic> json) {
    return HDManagerModel(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        avatarUrl: json['avatarUrl'],
        status: json['status']
    );
  }
}
