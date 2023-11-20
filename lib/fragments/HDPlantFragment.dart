import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:Detection/main.dart';
import 'package:Detection/models/HDClassModel.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';
import '../screens/HDClassDetailScreen.dart';
import '../screens/HDPlantDetailScreen.dart';
import '../utils/MIAColors.dart';
import '../utils/MIAWidgets.dart';

class HDPlantFragment extends StatefulWidget {
  const HDPlantFragment({Key? key}) : super(key: key);

  @override
  State<HDPlantFragment> createState() => _HDPlantFragmentState();
}

class _HDPlantFragmentState extends State<HDPlantFragment> {
  TextEditingController PlantSearchController = TextEditingController();
  TextEditingController CategoriesSearchController = TextEditingController();
  bool hasFetchCategories = false;
  Map<String, String> categoryMap = {};
  bool isSearching = false;
  bool isDataAvailable = false;
  int totalRow = 0;
  int pageNum = 0;
  bool _atBottom = false;
  bool isLastPage = false;
  DateTime? lastFetchTime;
  List<String> categories = [];
  bool isLoadingMoreData = false;
  String selectedCategory = 'Categories';
  String selectedCategoryId = '';
  bool isLoading = false;
  final apiUrl = APIUrl.getUrl();

  ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    changeStatusColor(appStore.scaffoldBackground!);
    super.initState();
    if (!hasFetchCategories) {
      fetchCategories(apiUrl, '');
    }
  }

  @override
  void dispose() {
    _scrollController
        .removeListener(_onScroll); // Xóa listener khi widget bị dispose
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if ((pageNum < totalRow / 10 - 1) && isLoadingMoreData && _atBottom) {
      if (lastFetchTime == null ||
          DateTime.now().difference(lastFetchTime!) > Duration(seconds: 1)) {
        setState(() {
          pageNum = pageNum + 1;
        });
        lastFetchTime = DateTime.now();
        await fetchMorePlant(apiUrl, PlantSearchController.text, pageNum);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: miaFragmentAppBar(context, 'Plant', false),
        body: NotificationListener<ScrollNotification>(
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
              child: Column(
                children: [
                  Divider(height: 2, color: Colors.black),
                  if (isLoading) // Hiển thị CircularProgressIndicator nếu isLoading là true
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ), //,
                    ),
                  if (!isLoading)
                    Column(
                      children: [
                        20.height,
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              searchFieldProps: TextFieldProps(
                                  controller: CategoriesSearchController,
                                  decoration: InputDecoration(
                                    labelText: 'Search',
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    prefixIcon: Icon(Icons.search),
                                  )),
                            ),
                            items: categories,
                            onChanged: (value) {
                              String? categoryId = categoryMap[value] ?? '';
                              setState(() {
                                selectedCategoryId = categoryId as String;
                                selectedCategory = value as String;
                              });
                            },
                            selectedItem: selectedCategory,
                          ),
                        ),
                        20.height,
                        Container(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: TextFormField(
                            controller: PlantSearchController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(top:16, left: 16, right: 16),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                data = [];
                                pageNum =
                                0; // Xóa dữ liệu hiện tại bằng cách gán danh sách thành mảng rỗng
                                isSearching = true;
                                isLastPage = false;
                              });
                              await fetchPlant(
                                  apiUrl, PlantSearchController.text, pageNum);
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty
                                  .resolveWith(
                                      (states) =>
                                      Size(200,
                                          50)),
                              shape: MaterialStateProperty
                                  .all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      12.0), // Điều chỉnh giá trị theo ý muốn
                                ),
                              ),
                            ),
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.black,
                                // Đặt màu cho văn bản
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        20.height,
                        isSearching
                            ? (isDataAvailable)
                                ? SingleChildScrollView(
                                    child: Column(
                                      children: data.map((plant) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 24.0,
                                              left: 12,
                                              right: 12),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.black12,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 12,
                                                      left: 8,
                                                      right: 12,
                                                      bottom: 12),
                                                  child: Container(
                                                      width: 100,
                                                      height: 100,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        // Điều chỉnh giá trị theo ý muốn
                                                        child: Image.network(
                                                          plant['images'][0]
                                                                  ['url'] ??
                                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                ),
                                                Container(
                                                  height: 110,
                                                  width: 100,
                                                  child: Column(
                                                    children: [
                                                      Flexible(
                                                        flex: 1,
                                                        child: Text(
                                                          '${plant['name']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18.0),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: Container(),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: Container(),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 150,
                                                  // Điều chỉnh kích thước theo ý muốn của bạn
                                                  height: 110,
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 12,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      HDPlantDetailScreen(
                                                                          id: plant[
                                                                              'id'])),
                                                            );
                                                          },
                                                          style: ButtonStyle(
                                                            minimumSize: MaterialStateProperty
                                                                .resolveWith(
                                                                    (states) =>
                                                                        Size(70,
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
                                                            'View Detail',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                  )
                                : Text('Plant not found',
                                    style: boldTextStyle(
                                        color: Colors.red,
                                        size:
                                            20)) // Sẽ hiển thị khi có dữ liệu và đang tìm kiếm
                            : SizedBox(),
                        (isLoadingMoreData)
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                ),
                              )
                            : SizedBox(
                                height: 40,
                              ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> fetchPlant(String apiUrl, String search, int pageNumber) async {
    setState(() {
      isLoading = true;
      data = [];
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
    };
    var api = apiUrl + '/api/plants';
    try {
      if (selectedCategoryId != '' && search == '')
        api =
            api + '?categoryId=${selectedCategoryId}&pageNumber=${pageNumber}';
      else if (search != '' && selectedCategoryId == '')
        api = api + '?name=${search}&pageNumber=${pageNumber}';
      else if (search != '' && selectedCategoryId != '')
        api = api +
            '?categoryId=${selectedCategoryId}&name=${search}&pageNumber=${pageNumber}';
      else
        api = api + '?pageNumber=${pageNumber}';
      final response = await http.get(Uri.parse(api), headers: bearerHeaders);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          totalRow = jsonResponse['pagination']['totalRow'];
          if (pageNum >= totalRow / 10 - 1) isLastPage = true;
          isLoading = false;
          final List<Map<String, dynamic>> body =
              jsonResponse['data'].cast<Map<String, dynamic>>();
          data = body;
          isDataAvailable = data.isNotEmpty;
        });
      } else {
        setState(() {
          isLoading = false;
          isDataAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isDataAvailable = false;
      });
    }
  }

  Future<void> fetchMorePlant(
      String apiUrl, String search, int pageNumber) async {
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
    };
    var api = apiUrl + '/api/plants';
    try {
      if (selectedCategoryId != '' && search == '')
        api =
            api + '?categoryId=${selectedCategoryId}&pageNumber=${pageNumber}';
      else if (search != '' && selectedCategoryId == '')
        api = api + '?name=${search}&pageNumber=${pageNumber}';
      else if (search != '' && selectedCategoryId != '')
        api = api +
            '?categoryId=${selectedCategoryId}&name=${search}&pageNumber=${pageNumber}';
      else
        api = api + '?pageNumber=${pageNumber}';
      final response = await http.get(Uri.parse(api), headers: bearerHeaders);
      if (response.statusCode == 200) {
        isLoadingMoreData = false;
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          if (pageNum >= totalRow - 1) isLastPage = true;
          final List<Map<String, dynamic>> newData =
              jsonResponse['data'].cast<Map<String, dynamic>>();
          data.addAll(newData);
          isDataAvailable = data.isNotEmpty;
        });
      } else {
        setState(() {
          isLoadingMoreData = false;
          isDataAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMoreData = false;
        isDataAvailable = false;
      });
    }
  }

  Future<void> fetchCategories(String apiUrl, String name) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl + '/api/categories'),
          headers: bearerHeaders);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data')) {
          List<dynamic> data = jsonResponse['data'];
          for (var item in data) {
            if (item['name'] != null && item['id'] != null) {
              String categoryName = item['name'].toString();
              String categoryId = item['id'].toString();
              categoryMap[categoryName] = categoryId; // Thêm entry vào Map
            }
          }
          setState(() {
            isLoading = false;
            categories = ["Categories", ...categoryMap.keys.toList()];
            hasFetchCategories = true;
            this.categoryMap = Map.from(categoryMap);
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
