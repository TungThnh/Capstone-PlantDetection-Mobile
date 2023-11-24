import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import '../providers/APIUrl.dart';
import '../utils/MIAColors.dart';

class HDPlantDetailScreen extends StatefulWidget {
  final String id;

  HDPlantDetailScreen({required this.id});

  @override
  State<HDPlantDetailScreen> createState() => _HDPlantDetailScreenState();
}

class _HDPlantDetailScreenState extends State<HDPlantDetailScreen> {
  late Map<String, dynamic> plant;
  final apiUrl = APIUrl.getUrl();
  bool hasFetchedData = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String id = widget.id;
    if (!hasFetchedData) {
      try {
        Map<String, dynamic>? fetchedPlant = await fetchPlant(apiUrl, id);
        if (fetchedPlant != null) {
          setState(() {
            plant = fetchedPlant;
            hasFetchedData = true;
          });
        } else {}
      } catch (e) {}
    }
  }

  Future<Map<String, dynamic>> fetchPlant(String apiUrl, id) async {
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
      };

      final response = await http.get(
        Uri.parse(apiUrl + '/api/plants/$id'),
        headers: bearerHeaders,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return jsonMap;
      } else {
        throw Exception(
            'Failed to fetch data'); // Sử dụng throw để ném một Exception
      }
    } catch (e) {
      throw Exception(
          'Failed to fetch data: $e'); // Ném một Exception với thông tin lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.pop(context);
            },
          ).paddingSymmetric(horizontal: 8),
          title: Padding(
            padding: EdgeInsets.only(left: 68),
            child: Text(
              'Plant Details',
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
              Padding(
                padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                // Chỉ định padding bên trái
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
                      plant['images'][_currentImageIndex]['url'] ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: plant['images'].map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            _onSliderChanged(plant['images'].indexOf(item));
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                                item['url'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12),
                // Chỉ định padding bên trái
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // Căn lề bên trái
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '${plant['name']}' ?? 'Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24.0),
                        ),
                      ),
                      10.height,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Họ: ${plant['plantCategories'][0]['category']['name']}' ??
                                  'Categories',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                          ),
                          Expanded(
                            child: (plant['livingCondition'] != null)
                                ? Text(
                                    'Nhiệt độ: ${plant['livingCondition']}' ??
                                        'livingCondition',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                      (plant['livingCondition'] != null || plant['ph'] != null)
                          ? 10.height
                          : SizedBox(),
                      Row(
                        children: [
                          Expanded(
                            child: (plant['ph'] != null)
                                ? Text(
                                    'Độ ph: ${plant['ph']}' ?? 'ph',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  )
                                : SizedBox(),
                          ),
                          Expanded(
                            child: (plant['distributionArea'] != null)
                                ? Text(
                                    'Phân bố: ${plant['distributionArea']}' ??
                                        'distributionArea',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                      (plant['scienceName'] != null ||
                          plant['fruitTime'] != null)
                          ? 10.height
                          : SizedBox(),
                      Row(
                        children: [
                          Expanded(
                            child: (plant['fruitTime'] != null)
                                ? Text(
                              'Năm ra hoa: ${plant['fruitTime']}' ??
                                  'fruitTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                              softWrap: true,
                            )
                                : SizedBox(),
                          ),
                          Expanded(
                            child: (plant['scienceName'] != null)
                                ? Text(
                              'Tên khoa học: ${plant['scienceName']}' ??
                                  'scienceName',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                              softWrap: true,
                            )
                                : SizedBox(),
                          ),
                        ],
                      ),
                      (plant['genus'] != null ||
                          plant['species'] != null)
                          ? 10.height
                          : SizedBox(),
                      Row(
                        children: [
                          Expanded(
                            child: (plant['genus'] != null)
                                ? Text(
                              'Chi: ${plant['genus']}' ??
                                  'fruitTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                              softWrap: true,
                            )
                                : SizedBox(),
                          ),
                          Expanded(
                            child: (plant['species'] != null)
                                ? Text(
                              'Giống loài: ${plant['species']}' ??
                                  'scienceName',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                              softWrap: true,
                            )
                                : SizedBox(),
                          ),
                        ],
                      ),
                      (plant['uses'] != null)
                          ? Column(children: [
                              10.height,
                              Text(
                                'Công dụng: ${plant['uses']}' ?? 'uses',
                                style: TextStyle(
                                  fontSize: 16,
                                  // Kích thước chữ
                                  fontWeight:
                                      FontWeight.bold, // Trọng lượng chữ
                                ),
                              ),
                            ])
                          : SizedBox(),
                      (plant['conservationStatus'] != null)
                          ? Column(children: [
                        10.height,
                        Text(
                          'Tình trạng bảo tồn: ${plant['conservationStatus']}' ?? 'conservationStatus',
                          style: TextStyle(
                            fontSize: 16,
                            // Kích thước chữ
                            fontWeight:
                            FontWeight.bold, // Trọng lượng chữ
                          ),
                        ),
                      ])
                          : SizedBox(),
                      10.height,
                      Text(
                        '${plant['description']}' ?? 'Description',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          // Độ mờ màu chữ
                          fontSize: 16,
                          // Kích thước chữ
                          fontWeight: FontWeight.normal, // Trọng lượng chữ
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _onSliderChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }
}
