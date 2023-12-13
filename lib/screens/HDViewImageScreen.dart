import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nb_utils/nb_utils.dart';

import '../providers/APIUrl.dart';
import '../utils/MIAColors.dart';
import 'HDViewResultScreen.dart';

class HDViewImageScreen extends StatefulWidget {
  final File? image;

  HDViewImageScreen({this.image});

  @override
  _HDViewImageScreenState createState() => _HDViewImageScreenState();
}

class _HDViewImageScreenState extends State<HDViewImageScreen> {
  File? _image;

  final apiUrl = APIUrl.getUrl();

  @override
  void initState() {
    super.initState();
    _image = widget.image;
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_upload, color: miaPrimaryColor),
            onPressed: () {
              uploadImage();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null ? Text("Chưa có ảnh") : Image.file(_image!),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Gọi hàm crop ảnh tại đây
                    openImageCropper(_image!.path ?? '');
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                            (states) => Size(80, 50)),
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
                        Icons.edit,
                        color: Colors.black,
                      ),
                      10.width,
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.black,
                          // Đặt màu cho văn bản
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _image = widget.image;
                    });
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                            (states) => Size(120, 50)),
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
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      10.width,
                      Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          // Đặt màu cho văn bản
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void uploadImage() async {
    showLoadingDialog(context);
    var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl + '/api/predictions'));
    var path = _image?.path ?? '';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Tên trường tệp ảnh trên API
        path, // Xác định loại tệp
      ),
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    var response = await request.send();
    if (response.statusCode == 200) {
      hideLoadingDialog(context);
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HDViewResultScreen(data: data),
        ),
      );
    } else {
      hideLoadingDialog(context);
      print('Có lỗi xảy ra khi gửi ảnh.');
    }
  }

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Không đóng dialog bằng cách tap ra ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(), // Hiển thị vòng loading
              SizedBox(width: 20),
              Text('Uploading...'), // Thông báo "Loading"
            ],
          ),
        );
      },
    );
  }

// Hàm để ẩn AlertDialog loading
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  Future<void> openImageCropper(String imagePath) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: false,
      ),
    );
    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
      });
    }
  }
}
