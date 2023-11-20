import 'HDManagerModel.dart';

class HDClassModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final String createAt;
  final String thumbnailUrl;
  final int numberOfMember;
  final String status;
  final HDManagerModel manager;

  HDClassModel({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.code,
    required this.description,
    required this.createAt,
    required this.numberOfMember,
    required this.status,
    required this.manager,
  });

  factory HDClassModel.fromJson(Map<String, dynamic> json) {
    return HDClassModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      createAt: json['createAt'],
      numberOfMember: json['numberOfMember'],
      status: json['status'],
      manager: HDManagerModel.fromJson(json['manager']),
    );
  }
}
