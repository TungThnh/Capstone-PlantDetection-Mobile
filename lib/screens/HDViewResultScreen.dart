import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/MIAColors.dart';
import 'HDPlantDetailScreen.dart';

class HDViewResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  HDViewResultScreen({required this.data});

  @override
  State<HDViewResultScreen> createState() => _HDViewResultScreenState();
}

class _HDViewResultScreenState extends State<HDViewResultScreen> {
  late Map<String, dynamic> data;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
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
      body: Container(
        child: data['plant'] != null
            ? _buildPlantInfo(data['plant'])
            : _buildEstimates(data['estimate']),
      ),
    );
  }

  void _onSliderChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  Widget _buildPlantInfo(Map<String, dynamic> plant) {
    return SingleChildScrollView(
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
                  plant['images'][_currentImageIndex]['url'],
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
          // SizedBox(height: 20),
          // Center(
          //   child: Padding(
          //     padding: EdgeInsets.only(left: 12, right: 12, bottom: 24),
          //     child: Container(
          //       width: double.infinity, // Đặt width là 100%
          //       height: 50,
          //       child: ElevatedButton(
          //         onPressed: () async {},
          //         style: ButtonStyle(
          //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //             RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(
          //                   48.0), // Điều chỉnh giá trị theo ý muốn
          //             ),
          //           ),
          //         ),
          //         child: Text(
          //           'Report',
          //           style: TextStyle(
          //             color: Colors.white, // Đặt màu cho văn bản
          //             fontSize: 20, // Đặt kích thước của văn bản (tuỳ chọn)
          //             fontWeight:
          //                 FontWeight.bold, // Đặt độ đậm của văn bản (tuỳ chọn)
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12),
            // Chỉ định padding bên trái
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // Căn lề bên trái
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plant['name']}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                  ),
                  Text(
                    '${plant['plantCategories'][0]['category']['name'] ?? 'abc'}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  Text(
                    '${plant['description'] ?? 'Description'}',
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
    );
  }

  Widget _buildEstimates(List<dynamic> estimates) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'Plant Undefine!',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Below are some similar results',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          for (var estimate in estimates)
            Padding(
              padding: EdgeInsets.only(bottom: 24.0, left: 12, right: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 12, left: 8, right: 12, bottom: 12),
                      child: Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // Điều chỉnh giá trị theo ý muốn
                            child: Image.network(
                              estimate['plant']['images'][0]['url'] ??
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                              fit: BoxFit.cover,
                            ),
                          )),
                    ),
                    Container(
                      height: 110,
                      width: 60,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              '${estimate['plant']['name']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
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
                            child: Text(
                              '${(estimate['confidence'] * 100).toStringAsFixed(2)}%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 190, // Điều chỉnh kích thước theo ý muốn của bạn
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
                                      builder: (context) => HDPlantDetailScreen(
                                          id: estimate['plant']['id'])),
                                );
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.resolveWith(
                                    (states) => Size(70, 30)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
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
            ),
        ],
      ),
    );
  }
}
