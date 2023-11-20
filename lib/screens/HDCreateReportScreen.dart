import 'dart:convert';

import 'package:Detection/providers/APIUrl.dart';
import 'package:Detection/screens/HDManageReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';

import 'package:http/http.dart' as http;
import '../utils/MIAColors.dart';

class HDCreateReportScreen extends StatefulWidget {
  @override
  State<HDCreateReportScreen> createState() => _HDCreateReportScreenState();
}

class _HDCreateReportScreenState extends State<HDCreateReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? capturedImage;
  final apiUrl = APIUrl.getUrl();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lableController = TextEditingController();
    var descriptionController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    TextEditingController _imageTextFieldController = TextEditingController(
        text: capturedImage != null ? path.basename(capturedImage!.path) : '');

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
            'New Report',
            style: TextStyle(
              color: Colors.black, // Màu chữ
              fontWeight: FontWeight.bold,
              fontSize: 24.0, // Kích thước chữ
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
                width: double.infinity,
                child: TextFormField(
                  controller: _imageTextFieldController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    prefixIcon: Icon(Icons.image),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () async {
                        final XFile? picture = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (picture != null) {
                          setState(() {
                            capturedImage = File(picture.path);
                          });
                        }
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Image is required';
                    }
                    return null;
                  },
                  readOnly: true,
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  controller: lableController,
                  decoration: InputDecoration(
                    labelText: 'Label',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon:
                        Icon(Icons.label), //Thêm biểu tượng trước trường nhập
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Label is required';
                    }
                    return null;
                  },
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon: Icon(Icons.description),
                    //Thêm biểu tượng trước trường nhập
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Descriptions is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (capturedImage != null) {
                        try {
                          showLoadingDialog(context);
                          var request = http.MultipartRequest(
                              'POST', Uri.parse(apiUrl + '/api/reports'));
                          var path = capturedImage?.path ?? '';
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'image', // Tên trường tệp ảnh trên API
                              path, // Xác định loại tệp
                            ),
                          );
                          request.headers['Content-Type'] =
                              'multipart/form-data';
                          request.headers['Authorization'] =
                              'Bearer ${userProvider.accessToken}';
                          request.fields['label'] = lableController.text;
                          request.fields['description'] =
                              descriptionController.text;
                          try {
                            var streamedResponse = await request.send();
                            var response = await http.Response.fromStream(
                                streamedResponse);
                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              hideLoadingDialog(context);
                              Navigator.pop(context, true);
                              _showCreateSuccessDialog(context);
                            } else {
                              hideLoadingDialog(context);
                              print(
                                  'Failed to send report. Status code: ${response.statusCode}');
                            }
                          } catch (e) {
                            hideLoadingDialog(context);
                            print('Error: $e');
                          }
                        } catch (e) {}
                      }
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                        (states) => Size(120, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            24.0), // Điều chỉnh giá trị theo ý muốn
                      ),
                    ),
                  ),
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.white, // Đặt màu cho văn bản
                      fontSize: 18, // Đặt kích thước của văn bản (tuỳ chọn)
                      fontWeight:
                          FontWeight.bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Success'),
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

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
