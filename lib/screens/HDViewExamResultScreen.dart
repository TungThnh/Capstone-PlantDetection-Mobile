import 'dart:async';
import 'dart:convert';

import 'package:Detection/models/HDQuestionResultModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';
import '../models/HDQuestionModel.dart';
import '../utils/MIAColors.dart';

class HDViewExamResultScreen extends StatefulWidget {
  String examId;

  HDViewExamResultScreen({required this.examId});

  @override
  State<HDViewExamResultScreen> createState() => _HDViewExamResultScreenState();
}

class _HDViewExamResultScreenState extends State<HDViewExamResultScreen> {
  final apiUrl = APIUrl.getUrl();
  bool hasFetchedData = false;
  late String examId;
  late List<HDQuestionModel> questions = [];
  late double score = 0;
  late List<HDQuestionResultModel> questionResults = [];

  @override
  void initState() {
    super.initState();
    examId = widget.examId;
  }

  Future<void> fetchExam(String apiUrl, String accessToken) async {
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': 'Bearer $accessToken',
      };
      final response = await http.get(
        Uri.parse(apiUrl + '/api/exams/$examId/results'),
        headers: bearerHeaders,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        if (jsonMap.containsKey('questionExams')) {
          List<HDQuestionModel> newQuestions = [];
          for (var question in jsonMap['questionExams']) {
            HDQuestionModel newQuestion =
                HDQuestionModel.fromJson(question['question']);
            newQuestions.add(newQuestion);
          }
          List<HDQuestionResultModel> newQuestionResults = [];
          for (var questionResult in jsonMap['questionExams']) {
            HDQuestionResultModel newQuestionResult =
                HDQuestionResultModel.fromJson(questionResult);
            newQuestionResults.add(newQuestionResult);
          }
          setState(() {
            score = jsonMap['score'] ?? 0.0;
            questions = newQuestions;
            questionResults = newQuestionResults;
          });
        } else {
          throw Exception('Invalid exam data: Missing "questions" key');
        }
      } else {
        throw Exception('Failed to fetch exam');
      }
    } catch (e) {
      throw Exception('Failed to fetch exam: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasFetchedData) {
      try {
        final userProvider = Provider.of<UserProvider>(context);
        String? accessToken = userProvider.accessToken;
        fetchExam(apiUrl, accessToken as String);
        hasFetchedData = true;
      } catch (e) {}
    }
    if (!hasFetchedData)
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ), //,
      );
    else
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ).paddingSymmetric(horizontal: 8),
          title: Padding(
            padding: EdgeInsets.only(left: 96),
            child: Text(
              'Result',
              style: TextStyle(
                color: Colors.black, // Màu chữ
                fontWeight: FontWeight.bold,
                fontSize: 24.0, // Kích thước chữ
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Score: ${score}/10.0',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              10.height,
              for (var question in questions)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 12, left: 24, right: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 2, color: Colors.black),
                          Text(
                            'Question ${getIndexById(questions, question.id) + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 12, right: 12),
                            // Chỉ định padding bên trái
                            child: Center(
                              child: Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black12,
                                    // Màu viền cho hình ảnh xem trước được chọn
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  // Điều chỉnh giá trị theo ý muốn
                                  child: Image.network(
                                    question.imageUrl ??
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${question.title}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          Row(
                            children: [
                              Text(
                                'A. ${question.answerA}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'B. ${question.answerB}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'C. ${question.answerC}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'D. ${question.answerD}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          Text(
                            'Correct answer: ${question.correctAnswer ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          (questionResults[getIndexResultById(
                                          questionResults, question.id)]
                                      .selectedAnswer !=
                                  " ")
                              ? (questionResults[getIndexResultById(
                                              questionResults, question.id)]
                                          .selectedAnswer ==
                                      question.correctAnswer)
                                  ? Text(
                                      'Selected answer: ${questionResults[getIndexResultById(questionResults, question.id)].selectedAnswer}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Text(
                                      'Selected answer: ${questionResults[getIndexResultById(questionResults, question.id)].selectedAnswer}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    )
                              : Text(
                                  'Selected answer: not chosen',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                          (questionResults[getIndexResultById(
                                          questionResults, question.id)]
                                      .selectedAnswer ==
                                  question.correctAnswer)
                              ? Text(
                                  'Score: 1.0/1.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                )
                              : Text(
                                  'Score: 0.0/1.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
  }

  int getIndexById(List<HDQuestionModel> questions, String id) {
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].id == id) {
        return i;
      }
    }
    return -1; // Trả về -1 nếu không tìm thấy id trong danh sách
  }

  int getIndexResultById(List<HDQuestionResultModel> results, String id) {
    for (int i = 0; i < results.length; i++) {
      if (results[i].question.id == id) {
        return i;
      }
    }
    return -1; // Trả về -1 nếu không tìm thấy id trong danh sách
  }
}
