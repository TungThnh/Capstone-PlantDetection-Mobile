import 'HDManagerModel.dart';

class HDQuestionModel {
  final String id;
  final String title;
  final String imageUrl;
  final String answerA;
  final String answerB;
  final String answerC;
  final String answerD;
  final String? correctAnswer;



  HDQuestionModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.answerA,
    required this.answerB,
    required this.answerC,
    required this.answerD,
    this.correctAnswer,
  });

  factory HDQuestionModel.fromJson(Map<String, dynamic> json) {
    return HDQuestionModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      answerA: json['answerA'],
      answerB: json['answerB'],
      answerC: json['answerC'],
      answerD: json['answerD'],
      correctAnswer: json['correctAnswer'] ?? '',
    );
  }
}
