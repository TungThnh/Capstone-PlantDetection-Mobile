import 'dart:convert';

import 'package:Detection/screens/HDCreateReportScreen.dart';
import 'package:Detection/screens/HDReportDetailScreen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:Detection/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';
import '../utils/MIAColors.dart';
import '../utils/MIAWidgets.dart';

class HDManageReportScreen extends StatefulWidget {
  final String classId;

  HDManageReportScreen({required this.classId});

  @override
  State<HDManageReportScreen> createState() => _HDManageReportScreenState();
}

class _HDManageReportScreenState extends State<HDManageReportScreen> {
  String classId = '';
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool hasFetchLabels = false;
  bool hasFetchedData = false;
  bool _atBottom = false;
  List<String> labels = [];
  List<String> sorts = ['None', 'Latest', 'Oldest'];
  Map<String, String> labelMap = {};
  ScrollController _scrollController = ScrollController();
  bool isLastPage = false;
  int totalRow = 0;
  int pageNum = 0;
  String selectedLabel = 'Labels';
  String selectedSort = 'None';
  String selectedLabelId = '';

  final apiUrl = APIUrl.getUrl();

  List<Map<String, dynamic>> data = [];

  DateTime? lastFetchTime;

  @override
  void initState() {
    changeStatusColor(appStore.scaffoldBackground!);
    super.initState();
    classId = widget.classId;
    if (!hasFetchLabels) {
      fetchLabels(apiUrl, classId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiUrl = APIUrl.getUrl();
    final userProvider = Provider.of<UserProvider>(context);
    String? accessToken = userProvider.accessToken;

    if (!hasFetchedData) {
      fetchReports(apiUrl, accessToken!, 'Labels', selectedSort);
      setState(() {
        hasFetchedData = true;
      });
    }

    void _onScroll() async {
      if ((pageNum < totalRow / 10 - 1) && isLoadingMoreData && _atBottom) {
        if (lastFetchTime == null ||
            DateTime.now().difference(lastFetchTime!) > Duration(seconds: 1)) {
          setState(() {
            pageNum = pageNum + 1;
          });
          lastFetchTime = DateTime.now();
          (selectedLabel == 'Labels')
              ? await fetchMoreReports(
                  apiUrl, accessToken!, pageNum, 'Labels', selectedSort)
              : await fetchMoreReports(
                  apiUrl, accessToken!, pageNum, selectedLabelId, selectedSort);
        }
      }
    }

    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ).paddingSymmetric(horizontal: 8),
          title: Padding(
            padding: EdgeInsets.only(left: 92),
            child: Text(
              'Send data',
              style: TextStyle(
                color: Colors.black, // Màu chữ
                fontWeight: FontWeight.bold,
                fontSize: 24.0, // Kích thước chữ
              ),
            ),
          ),
        ),
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
                      Padding(
                        padding: EdgeInsets.only(
                            top: 12, bottom: 12, left: 300, right: 12),
                        child: ElevatedButton(
                          onPressed: () async {
                            final reLoad = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HDCreateReportScreen(classId: classId),
                              ),
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
                            }
                          },
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.resolveWith(
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
                            children: [
                              Text(
                                'New',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.add, size: 30, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8, left: 16.0, right: 16.0, bottom: 20),
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                          ),
                          items: labels,
                          onChanged: (value) {
                            String? labelId = labelMap[value] ?? '';
                            setState(() {
                              selectedLabelId = labelId as String;
                              selectedLabel = value as String;
                              if (selectedLabel != 'Labels') {
                                fetchReports(apiUrl, accessToken!,
                                    selectedLabelId, selectedSort);
                              } else {
                                fetchReports(apiUrl, accessToken!,
                                    selectedLabel, selectedSort);
                              }
                            });
                          },
                          selectedItem: selectedLabel,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8, left: 16.0, right: 16.0, bottom: 20),
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                          ),
                          items: sorts,
                          onChanged: (value) {
                            setState(() {
                              selectedSort = value!;
                              if (selectedLabel != 'Labels') {
                                fetchReports(apiUrl, accessToken!,
                                    selectedLabelId, selectedSort);
                              } else {
                                fetchReports(apiUrl, accessToken!,
                                    selectedLabel, selectedSort);
                              }
                            });
                          },
                          selectedItem: selectedSort,
                        ),
                      ),
                      (data.isEmpty)
                          ? Text('Reports empty')
                          : Column(
                              children: data.map((report) {
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
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Container(
                                              width: 100,
                                              height: 100,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                // Điều chỉnh giá trị theo ý muốn
                                                child: Image.network(
                                                  report['imageUrl'] ??
                                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ),
                                        Container(
                                          height: 120,
                                          width: 150,
                                          child: Column(
                                            children: [
                                              6.height,
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  '${report['label']['name']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: Container(),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Text(
                                                  '${report['description'].length > 45 ? '${report['description'].substring(0, 45)}...' // Cắt sau số ký tự maxLength và thêm dấu "..."
                                                      : report['description']}',
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 120,
                                          // Điều chỉnh kích thước theo ý muốn của bạn
                                          height: 110,
                                          child: Stack(
                                            children: [
                                              (report['status'] == 'Pending')
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8, left: 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.yellow,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 8,
                                                                right: 8),
                                                        child: Text(
                                                            report['status']),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (report['status'] == 'Approved')
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8, left: 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 8,
                                                                right: 8),
                                                        child: Text(
                                                            report['status']),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (report['status'] ==
                                                      'In Progress')
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8, left: 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 8,
                                                                right: 8),
                                                        child: Text(
                                                            report['status']),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (report['status'] == 'Processed')
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8, left: 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 8,
                                                                right: 8),
                                                        child: Text(
                                                            report['status']),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (report['status'] == 'Rejected')
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8, left: 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 8,
                                                                right: 8),
                                                        child: Text(
                                                            report['status']),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              Positioned(
                                                bottom: 0,
                                                right: 12,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HDReportDetailScreen(
                                                                  id: report[
                                                                      'id'])),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    minimumSize:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) =>
                                                                    Size(70,
                                                                        30)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6.0), // Điều chỉnh giá trị theo ý muốn
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'View Detail',
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

  Future<void> fetchReports(
      String apiUrl, String accessToken, String labelId, String sort) async {
    setState(() {
      isLoading = true;
      data = [];
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer ${accessToken}',
    };
    try {
      final response = (selectedLabel == 'Labels')
          ? ((sort == 'None')
              ? await http.get(Uri.parse(apiUrl + '/api/reports/students'),
                  headers: bearerHeaders)
              : (sort == 'Latest')
                  ? await http.get(
                      Uri.parse(apiUrl + '/api/reports/students?latest=true'),
                      headers: bearerHeaders)
                  : await http.get(
                      Uri.parse(apiUrl + '/api/reports/students?latest=false'),
                      headers: bearerHeaders))
          : ((sort == 'None')
              ? await http.get(
                  Uri.parse(
                      apiUrl + '/api/reports/students?labelId=${labelId}'),
                  headers: bearerHeaders)
              : (sort == 'Latest')
                  ? await http.get(
                      Uri.parse(apiUrl +
                          '/api/reports/students?labelId=${labelId}&latest=true'),
                      headers: bearerHeaders)
                  : await http.get(
                      Uri.parse(apiUrl + '/api/reports/students?labelId=${labelId}&latest=false'),
                      headers: bearerHeaders));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          totalRow = jsonResponse['pagination']['totalRow'];
          if (pageNum >= totalRow / 10 - 1) isLastPage = true;
          final List<Map<String, dynamic>> body =
              jsonResponse['data'].cast<Map<String, dynamic>>();
          data = body;
          isLoading = false;
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

  Future<void> fetchMoreReports(String apiUrl, String acceessToken,
      int pageNumber, String labelId, String sort) async {
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer ${acceessToken}',
    };
    try {
      final response = (selectedLabel == 'Labels')
          ? ((sort == 'None')
              ? await http
                  .get(Uri.parse(apiUrl + '/api/reports/students?pageNumber=${pageNumber}'),
                      headers: bearerHeaders)
              : (sort == 'Latest')
                  ? await http.get(
                      Uri.parse(apiUrl +
                          '/api/reports/students?pageNumber=${pageNumber}&latest=true'),
                      headers: bearerHeaders)
                  : await http.get(
                      Uri.parse(apiUrl +
                          '/api/reports/students?pageNumber=${pageNumber}&latest=false'),
                      headers: bearerHeaders))
          : ((sort == 'None')
              ? await http.get(
                  Uri.parse(apiUrl +
                      '/api/reports/students?labelId=${labelId}&pageNumber=${pageNumber}'),
                  headers: bearerHeaders)
              : (sort == 'Latest')
                  ? await http
                      .get(Uri.parse(apiUrl + '/api/reports/students?labelId=${labelId}&pageNumber=${pageNumber}&latest=true'),
                          headers: bearerHeaders)
                  : await http.get(
                      Uri.parse(apiUrl + '/api/reports/students?labelId=${labelId}&pageNumber=${pageNumber}&latest=false'),
                      headers: bearerHeaders));

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

  Future<void> fetchLabels(String apiUrl, String classId) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
    };

    try {
      final response = await http.get(
          Uri.parse(apiUrl + '/api/labels?classId=${classId}'),
          headers: bearerHeaders);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data')) {
          List<dynamic> data = jsonResponse['data'];
          for (var item in data) {
            if (item['name'] != null && item['id'] != null) {
              String categoryName = item['name'].toString();
              String categoryId = item['id'].toString();
              labelMap[categoryName] = categoryId; // Thêm entry vào Map
            }
          }
          setState(() {
            isLoading = false;
            labels = ["Labels", ...labelMap.keys.toList()];
            hasFetchLabels = true;
            this.labelMap = Map.from(labelMap);
          });
        } else {
          // Handle unexpected response structure
          setState(() {
            isLoading = false;
            // Handle error due to unexpected response structure
          });
        }
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
}
