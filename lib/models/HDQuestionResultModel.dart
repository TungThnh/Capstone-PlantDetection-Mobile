import 'package:Detection/models/HDQuestionModel.dart';


class HDQuestionResultModel {
  final HDQuestionModel question;
  final String selectedAnswer;




  HDQuestionResultModel({
    required this.question,
    required this.selectedAnswer,
  });

  factory HDQuestionResultModel.fromJson(Map<String, dynamic> json) {
    return HDQuestionResultModel(
      question: HDQuestionModel.fromJson(json['question']),
      selectedAnswer: json['selectedAnswer'],
      // Các trường khác nếu có
    );
  }
}
