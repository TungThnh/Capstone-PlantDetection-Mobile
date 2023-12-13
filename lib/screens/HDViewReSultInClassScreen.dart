import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/MIAColors.dart';
import 'HDPlantDetailScreen.dart';

class HDViewResultInClassScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  HDViewResultInClassScreen({required this.data});

  @override
  State<HDViewResultInClassScreen> createState() =>
      _HDViewResultInClassScreenState();
}

class _HDViewResultInClassScreenState extends State<HDViewResultInClassScreen> {
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
    final staticAnchorKey = GlobalKey();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12),
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
                  child: plant['images'] != null && plant['images'].isNotEmpty
                      ? Image.network(
                          plant['images'][_currentImageIndex]['url'],
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Divider(height: 2, color: Colors.black),
          SizedBox(height: 10),
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
          SizedBox(height: 10),
          Divider(height: 2, color: Colors.black),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12),
            // Chỉ định padding bên trái
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // Căn lề bên trái
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (plant['name'] != null && plant['name'] != '')
                        ? Center(
                            child: Text(
                              '${plant['name']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24.0),
                            ),
                          )
                        : Center(
                            child: Text(
                              'name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24.0),
                            ),
                          ),
                    10.height,
                    (plant['plantCategories'] != null)
                        ? Wrap(
                            children: [
                              Text(
                                'Họ: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              Text(
                                '${plant['plantCategories'][0]['category']['name']}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          )
                        : Wrap(
                            children: [
                              Text(
                                'Họ: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              Text(
                                'Chưa có thông tin!',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                    (plant['livingCondition'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Nhiệt độ: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  Text(
                                    '${plant['livingCondition']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  )
                                ],
                              )
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Nhiệt độ: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  )
                                ],
                              )
                            ],
                          ),
                    (plant['ph'] != null) ? 10.height : SizedBox(),
                    (plant['ph'] != null)
                        ? Wrap(
                            children: [
                              Text(
                                'Độ ph: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                                softWrap: true,
                              ),
                              Text(
                                '${plant['ph']}',
                                style: TextStyle(fontSize: 16.0),
                                softWrap: true,
                              )
                            ],
                          )
                        : Wrap(
                            children: [
                              Text(
                                'Độ ph: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                                softWrap: true,
                              ),
                              Text(
                                'Chưa có thông tin!',
                                style: TextStyle(fontSize: 16.0),
                                softWrap: true,
                              )
                            ],
                          ),
                    (plant['distributionArea'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Phân bố: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['distributionArea']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Phân bố: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['size'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Kích thước: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['size']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Kích thước: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['fruitTime'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Năm ra hoa: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['fruitTime']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Năm ra hoa: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['scienceName'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Tên khoa học: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['scienceName']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Tên khoa học: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['genus'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Chi: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['genus']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Chi: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['discoverer'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Người khám phá: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['discoverer']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Người khám phá: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['species'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Giống loài: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['species']}',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Giống loài: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['uses'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Công dụng: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['uses']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Công dụng: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    (plant['conservationStatus'] != null)
                        ? Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Tình trạng bảo tồn: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    '${plant['conservationStatus']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      // Kích thước chữ
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              10.height,
                              Wrap(
                                children: [
                                  Text(
                                    'Tình trạng bảo tồn: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                  Text(
                                    'Chưa có thông tin!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      // Kích thước chữ
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    10.height,
                    Html(
                      anchorKey: staticAnchorKey,
                      data: plant['description'],
                      style: {
                        "p": Style(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: FontSize(16),
                          // Kích thước chữ
                        ),
                        "span": Style(
                          backgroundColor: Colors.transparent,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: FontSize(16),
                          // Kích thước chữ
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          10.height,
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
          (estimates.isEmpty)
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'Can not detect any plant in the photo',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'Below are some similar results',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
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
                              '${(estimate['confidence'] * 100).toStringAsFixed(0)}%',
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
