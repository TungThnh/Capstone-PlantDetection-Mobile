import 'dart:convert';

import 'package:Detection/screens/HDExamScreen.dart';
import 'package:Detection/screens/HDViewExamResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:Detection/main.dart';
import 'package:Detection/models/HDClassModel.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';
import '../screens/HDClassDetailScreen.dart';
import '../utils/MIAColors.dart';
import '../utils/MIAWidgets.dart';

class HDGameFragment extends StatefulWidget {
  const HDGameFragment({Key? key}) : super(key: key);

  @override
  State<HDGameFragment> createState() => _HDGameFragmentState();
}

class _HDGameFragmentState extends State<HDGameFragment> {
  bool hasFetchedData = false;
  bool isLoading = false;
  bool isLoadingMoreData = false;
  final apiUrl = APIUrl.getUrl();
  bool _atBottom = false;
  ScrollController _scrollController = ScrollController();
  bool isLastPage = false;
  int totalRow = 0;
  int pageNum = 0;
  DateTime? lastFetchTime;

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    changeStatusColor(appStore.scaffoldBackground!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String? accessToken = userProvider.accessToken;
    if (!hasFetchedData) {
      fetchExam(apiUrl, accessToken as String);
    }
    void _onScroll() async {
      if ((pageNum < totalRow / 10 - 1) && isLoadingMoreData && _atBottom) {
        if (lastFetchTime == null ||
            DateTime.now().difference(lastFetchTime!) > Duration(seconds: 1)) {
          setState(() {
            pageNum = pageNum + 1;
          });
          lastFetchTime = DateTime.now();
          fetchMoreExam(apiUrl, accessToken as String, pageNum);
        }
      }
    }

    return Observer(builder: (context) {
      return Scaffold(
        appBar: miaFragmentAppBar(context, 'Game', false),
        body: (isLoading)
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification && !_atBottom) {
                    if (_scrollController.position.maxScrollExtent ==
                            scrollInfo.metrics.pixels &&
                        !isLastPage) {
                      setState(() {
                        isLoadingMoreData = true;
                      });
                      if (isLoadingMoreData) {
                        _atBottom = true;
                        _onScroll();
                      }
                    }
                  } else {
                    _atBottom = false;
                  }
                  return true;
                },
                child: Container(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(height: 2, color: Colors.black),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 16, bottom: 16, left: 16, right: 16),
                              child: Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final reLoad = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HDExamScreen()),
                                    );
                                    if (reLoad == true) {
                                      setState(() {
                                        isLoading = false;
                                        isLoadingMoreData = false;
                                        hasFetchedData = false;
                                        _atBottom = false;
                                        isLastPage = false;
                                        totalRow = 0;
                                        pageNum = 0;
                                        data = [];
                                        lastFetchTime = null;
                                      });
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        isLoadingMoreData = false;
                                        hasFetchedData = false;
                                        _atBottom = false;
                                        isLastPage = false;
                                        totalRow = 0;
                                        pageNum = 0;
                                        data = [];
                                        lastFetchTime = null;
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    minimumSize:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Size(200, 50)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Điều chỉnh giá trị theo ý muốn
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videogame_asset,
                                        color: Colors.black,
                                      ),
                                      10.width,
                                      Text(
                                        'Join a game',
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
                          ]).paddingSymmetric(horizontal: 16),
                      (data.isEmpty)
                          ? Text('Exam empty')
                          : Column(
                              children: data.map((exam) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 24.0, left: 12, right: 12),
                                  child: Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 6, top: 12),
                                          child: Container(
                                            width: 240,
                                            height: 100,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Examination',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                (exam['submitAt'] != null)
                                                    ? Text(
                                                        'Submit at: ${parseDate(exam['submitAt'])}')
                                                    : Text(
                                                        'Submit at: Chưa có thông tin'),
                                                10.height,
                                                (exam['score'] != null &&
                                                        exam['score'] > 4.0)
                                                    ? Row(
                                                        children: [
                                                          Text(
                                                            'Score: ${exam['score'] ?? 0.0}',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                          20.width,
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6),
                                                              child: Text(
                                                                'Passed',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : (exam['score'] != null &&
                                                            exam['score'] < 4.0)
                                                        ? Row(
                                                            children: [
                                                              Text(
                                                                'Score: ${exam['score'] ?? 0.0}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              20.width,
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  child: Text(
                                                                    'Not pass',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Text(
                                                              'Exam have not submitted yet!',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 120,
                                          // Điều chỉnh kích thước theo ý muốn của bạn
                                          height: 110,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                bottom: 0,
                                                right: 8,
                                                child: (!exam['isSubmitted'])
                                                    ? SizedBox()
                                                    : ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  HDViewExamResultScreen(
                                                                examId:
                                                                    exam['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: ButtonStyle(
                                                          minimumSize:
                                                              MaterialStateProperty
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          Size(
                                                                              70,
                                                                              30)),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.0), // Điều chỉnh giá trị theo ý muốn
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'View Result',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            // Đặt màu cho văn bản
                                                            fontSize: 12,
                                                            // Đặt kích thước của văn bản (tuỳ chọn)
                                                            fontWeight: FontWeight
                                                                .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                      (isLoadingMoreData)
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            )
                          : SizedBox(
                              height: 40,
                            ),
                    ]),
                  ),
                ),
              ),
      );
    });
  }

  Future<void> fetchExam(String apiUrl, String acceessToken) async {
    setState(() {
      isLoading = true;
      data = [];
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer ${acceessToken}',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl + '/api/exams/students'),
          headers: bearerHeaders);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          totalRow = jsonResponse['pagination']['totalRow'];
          if (pageNum >= totalRow / 10 - 1) isLastPage = true;
          final List<Map<String, dynamic>> body =
              jsonResponse['data'].cast<Map<String, dynamic>>();
          data = body;
          isLoading = false;
          hasFetchedData = true;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreExam(
      String apiUrl, String acceessToken, int pageNumber) async {
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer ${acceessToken}',
    };
    try {
      final response = await http.get(
          Uri.parse(apiUrl + '/api/exams/students?pageNumber=${pageNumber}'),
          headers: bearerHeaders);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          isLoadingMoreData = false;
          if (pageNum >= totalRow / 10 - 1) isLastPage = true;
          final List<Map<String, dynamic>> newData =
              jsonResponse['data'].cast<Map<String, dynamic>>();
          data.addAll(newData);
        });
      } else {
        setState(() {
          isLoadingMoreData = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMoreData = false;
      });
    }
  }
}

String? parseDate(String inputDate) {
  try {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    return formattedDate;
  } catch (e) {
    return null;
  }
}
