import 'dart:convert';

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

class HDClassFragment extends StatefulWidget {
  const HDClassFragment({Key? key}) : super(key: key);

  @override
  State<HDClassFragment> createState() => _HDClassFragmentState();
}

class _HDClassFragmentState extends State<HDClassFragment> {
  HDClassModel? currentClass;
  TextEditingController enrollCodeController = TextEditingController();
  bool isLoading = false;
  final apiUrl = APIUrl.getUrl();
  bool classNotFound = false;
  bool showEnrollInput = false;
  bool hasFetchedData = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    changeStatusColor(appStore.scaffoldBackground!);
    super.initState();
  }

  void handleEnrollButtonPress() {
    setState(() {
      showEnrollInput = true;
    });
  }

  void handleContainerTap(HDClassModel classModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HDClassDetailScreen(classModel: classModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String? accessToken = userProvider.accessToken;

    if (currentClass == null && !hasFetchedData) {
      fetchClasses(apiUrl, accessToken!);
      hasFetchedData = true;
    }

    return Observer(builder: (context) {
      return Scaffold(
        appBar: miaFragmentAppBar(context, 'Class', false),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Divider(height: 2, color: Colors.black),
            if (isLoading) // Hiển thị CircularProgressIndicator nếu isLoading là true
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ), //,
              ),
            if (!isLoading && currentClass == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You have not enrolled any class'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return QRView(
                              key: qrKey,
                              onQRViewCreated: _onQRViewCreated,
                            );
                          }),
                        );
                      },
                      child: Text('Enroll class with QR Code'),
                    ),
                  ],
                ),
              ),
            if (!isLoading && currentClass != null)
              GestureDetector(
                onTap: () => handleContainerTap(currentClass as HDClassModel),
                // Hiển thị mục nhập mã lớp nếu currentClass không null
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${currentClass!.code}',
                              style: TextStyle(
                                // Đặt màu cho văn bản
                                fontSize: 24,
                                // Đặt kích thước của văn bản (tuỳ chọn)
                                fontWeight: FontWeight
                                    .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              currentClass?.createAt != null
                                  ? DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(currentClass!.createAt))
                                  : 'CreateAt',
                              style: TextStyle(
                                // Đặt màu cho văn bản
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.height,
                        Container(
                          height: 250,
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
                              currentClass?.thumbnailUrl ??
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        10.height,
                        Text(
                          currentClass!.name.length > 30
                              ? ' ${currentClass!.name.substring(0, 30)}...'
                              : ' ${currentClass!.name}',
                          style: TextStyle(
                            // Đặt màu cho văn bản
                            fontSize: 16,
                            // Đặt kích thước của văn bản (tuỳ chọn), // Đặt độ đậm của văn bản (tuỳ chọn)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ]).paddingSymmetric(horizontal: 16),
        ),
      );
    });
  }

  Future<void> fetchClasses(String apiUrl, String acceessToken) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer ${acceessToken}',
    };
    try {
      final response = await http.get(
          Uri.parse(apiUrl + '/api/classes/student'),
          headers: bearerHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final HDClassModel responseClass = HDClassModel.fromJson(jsonResponse);

        setState(() {
          currentClass = responseClass;
          isLoading = false;
          hasFetchedData = true;
        });
      } else {
        setState(() {
          isLoading = false;
          hasFetchedData = true;
        });
      }
    } catch (e) {}
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        controller.stopCamera();
      });
      if (result != null && result!.code != null) {
        await findClassByCode(apiUrl, result!.code!);
        if (currentClass != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HDClassDetailScreen(classModel: currentClass!),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> findClassByCode(String apiUrl, String code) async {
    setState(() {
      currentClass = null;
      isLoading = true;
    });
    Map<String, String> bearerHeaders = {
      'Content-Type': 'application/json-patch+json',
    };

    try {
      final response = await http.get(
          Uri.parse(apiUrl + '/api/classes/code/${code}'),
          headers: bearerHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final HDClassModel responseClass = HDClassModel.fromJson(jsonResponse);
        setState(() {
          currentClass = responseClass;
          isLoading = false;
        });
      } else {
        setState(() {
          currentClass = null;
          isLoading = false;
        });
      }
    } catch (e) {}
  }
}
