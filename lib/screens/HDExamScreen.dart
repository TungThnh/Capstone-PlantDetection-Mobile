import 'dart:async';
import 'dart:convert';

import 'package:Detection/screens/HDViewExamResultScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';
import '../models/HDQuestionModel.dart';

class HDExamScreen extends StatefulWidget {
  HDExamScreen();

  @override
  State<HDExamScreen> createState() => _HDExamScreenState();
}

class _HDExamScreenState extends State<HDExamScreen> {
  final apiUrl = APIUrl.getUrl();
  bool hasFetchedData = false;
  late int timeRemaining; // Thời gian còn lại tính bằng giây
  late Timer timer;
  late List<HDQuestionModel> questions = [];
  late List<String> selectedAnswers;
  late String examId; // Được khởi tạo trong initState

  @override
  void initState() {
    super.initState();
    timeRemaining = 600; // 10 phút = 600 giây
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            _onSubmit();
            t.cancel(); // Hủy bộ đếm thời gian
          }
        });
      }
    });
  }

  void _onSubmit() async {
    showLoadingDialog(context);
    List<Map<String, String>> requestBody = [];
    for (int i = 0; i < questions.length; i++) {
      String questionId = questions[i].id;
      String selectedAnswer = selectedAnswers[i];

      Map<String, String> questionExam = {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
      };
      requestBody.add(questionExam);
    }
    try {
      if (examId != null) {
        final response = await http.put(
          Uri.parse(apiUrl + '/api/exams/${examId}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'questionExams': requestBody}),
        );
        if (response.statusCode == 200) {
          hideLoadingDialog(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HDViewExamResultScreen(
                examId: examId,
              ),
            ),
          ).then((value) => {
                if (value == true) {Navigator.pop(context, true)}
              });
          _showSubmitSuccessDialog(context);
        } else {
          hideLoadingDialog(context);
          print('API request failed with status code: ${response.statusCode}');
        }
      } else {
        hideLoadingDialog(context);
        print('exam id ko lay dc');
      }
    } catch (e) {
      hideLoadingDialog(context);
      print('Error during API request: $e');
    }
  }

  Future<void> fetchExam(String apiUrl, String accessToken) async {
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.post(
        Uri.parse(apiUrl + '/api/exams/'),
        headers: bearerHeaders,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        // Kiểm tra xem key 'questions' có tồn tại trong jsonMap hay không
        if (jsonMap.containsKey('questionExams')) {
          List<HDQuestionModel> newQuestions = [];
          for (var question in jsonMap['questionExams']) {
            HDQuestionModel newQuestion =
                HDQuestionModel.fromJson(question['question']);
            newQuestions.add(newQuestion);
          }
          setState(() {
            questions = newQuestions;
            examId = jsonMap['id'];
            selectedAnswers = List.filled(questions.length, '');
          });
        } else {
          throw Exception('Invalid exam data: Missing "questions" key');
        }
      } else {
        throw Exception('Failed to fetch exam: ${response.statusCode}');
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
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(left: 124),
            child: Text(
              'Mini Game',
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
              // Hiển thị bộ đếm giờ
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Time left: ${formatTime(timeRemaining)}',
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                    selectedAnswers[getIndexById(
                                            questions, question.id)] =
                                        (selectedAnswers[getIndexById(
                                                    questions, question.id)] ==
                                                'A')
                                            ? ""
                                            : 'A';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'A',
                                      groupValue: selectedAnswers[
                                          getIndexById(questions, question.id)],
                                      onChanged: (value) {
                                        setState(() {
                                          // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                          selectedAnswers[getIndexById(
                                                  questions, question.id)] =
                                              (selectedAnswers[getIndexById(
                                                          questions,
                                                          question.id)] ==
                                                      'A')
                                                  ? ""
                                                  : 'A';
                                        });
                                      },
                                    ),
                                    Text(
                                      'A. ${question.answerA}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                    selectedAnswers[getIndexById(
                                            questions, question.id)] =
                                        (selectedAnswers[getIndexById(
                                                    questions, question.id)] ==
                                                'B')
                                            ? ""
                                            : 'B';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'B',
                                      groupValue: selectedAnswers[
                                          getIndexById(questions, question.id)],
                                      onChanged: (value) {
                                        setState(() {
                                          // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                          selectedAnswers[getIndexById(
                                                  questions, question.id)] =
                                              (selectedAnswers[getIndexById(
                                                          questions,
                                                          question.id)] ==
                                                      'B')
                                                  ? ""
                                                  : 'B';
                                        });
                                      },
                                    ),
                                    Text(
                                      'B. ${question.answerB}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                    selectedAnswers[getIndexById(
                                            questions, question.id)] =
                                        (selectedAnswers[getIndexById(
                                                    questions, question.id)] ==
                                                'C')
                                            ? ""
                                            : 'C';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'C',
                                      groupValue: selectedAnswers[
                                          getIndexById(questions, question.id)],
                                      onChanged: (value) {
                                        setState(() {
                                          // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                          selectedAnswers[getIndexById(
                                                  questions, question.id)] =
                                              (selectedAnswers[getIndexById(
                                                          questions,
                                                          question.id)] ==
                                                      'C')
                                                  ? ""
                                                  : 'C';
                                        });
                                      },
                                    ),
                                    Text(
                                      'C. ${question.answerC}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Đảo ngược trạng thái của radio khi nhấn vào dòng
                                    selectedAnswers[getIndexById(
                                            questions, question.id)] =
                                        (selectedAnswers[getIndexById(
                                                    questions, question.id)] ==
                                                'D')
                                            ? ""
                                            : 'D';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'D',
                                      groupValue: selectedAnswers[
                                          getIndexById(questions, question.id)],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAnswers[getIndexById(
                                                  questions, question.id)] =
                                              (selectedAnswers[getIndexById(
                                                          questions,
                                                          question.id)] ==
                                                      'D')
                                                  ? ""
                                                  : 'D';
                                        });
                                      },
                                    ),
                                    Text(
                                      'D. ${question.answerD}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              Padding(
                padding:
                    EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _onSubmit();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.resolveWith(
                          (states) => Size(200, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Điều chỉnh giá trị theo ý muốn
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.black,
                            // Đặt màu cho văn bản
                            fontSize: 18,
                            // Đặt kích thước của văn bản (tuỳ chọn)
                            fontWeight: FontWeight
                                .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int getIndexById(List<HDQuestionModel> questions, String id) {
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].id == id) {
        return i;
      }
    }
    return -1; // Trả về -1 nếu không tìm thấy id trong danh sách
  }

  void _showSubmitSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submitted'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng thông báo popup
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Không đóng dialog bằng cách tap ra ngoài
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ), // Hiển thị vòng loading
                SizedBox(width: 20),
              ],
            ),
          ),
        );
      },
    );
  }

// Hàm để ẩn AlertDialog loading
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
