import 'package:Detection/fragments/HDCameraFragment.dart';
import 'package:Detection/screens/HDViewImageScreen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:nb_utils/nb_utils.dart';

import '../utils/MIAColors.dart';

class HDTakePhotoScreen extends StatefulWidget {
  final CameraController controller;

  HDTakePhotoScreen({required this.controller});

  @override
  _HDTakePhotoScreenState createState() =>
      _HDTakePhotoScreenState(controller: controller);
}

class _HDTakePhotoScreenState extends State<HDTakePhotoScreen> {
  final CameraController controller;
  File? capturedImage;

  _HDTakePhotoScreenState({required this.controller});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
          onPressed: () {
           finish(context);
          },
        ).paddingSymmetric(horizontal: 8),
        title: TextButton(
          onPressed: () {
            finish(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
              color: Colors.green, // Màu chữ
              fontSize: 16.0, // Kích thước chữ
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 30,
      ),
      body: Center(
        child: Column(
          children: [
            // Widget để hiển thị hình ảnh từ camera
            CameraPreview(controller),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      showLoadingDialog(context);
                      final XFile? picture = await ImagePicker().pickImage(source: ImageSource.gallery);
                      hideLoadingDialog(context);
                      if (picture != null) {
                        File selectedImage = File(picture.path);
                        setState(() {
                          capturedImage = selectedImage; // Gán ảnh đã chọn vào capturedImage
                        });
                        // Chuyển đến màn hình xem ảnh
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HDViewImageScreen(image: capturedImage),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.collections, // Sử dụng biểu tượng bộ sưu tập
                            size: 40.0,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(top: 48.0, bottom: 48.0),
                        // Padding xung quanh nút
                        child: InkWell(
                          onTap: () async {
                            showLoadingDialog(context);
                            final XFile? picture =
                                await takePicture(controller);
                            hideLoadingDialog(context);
                            if (picture != null) {
                              setState(() {
                                // Gán ảnh đã chụp vào biến capturedImage
                                capturedImage = File(picture.path);
                                print(capturedImage);
                              });
                              // Chuyển đến màn hình xem ảnh
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HDViewImageScreen(image: capturedImage),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 68.0, // Điều chỉnh kích thước nút
                            height: 68.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.blue, // Điều chỉnh màu sắc nút tùy ý
                            ),
                            child: Center(
                              child: Icon(
                                Icons.camera,
                                color: Colors.white,
                                // Điều chỉnh màu sắc biểu tượng tùy ý
                                size:
                                    48.0, // Điều chỉnh kích thước biểu tượng tùy ý
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(), // Phần tử trống bên phải
                ),
              ],
            )
          ],
        ),
      ),
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
                CircularProgressIndicator(), // Hiển thị vòng loading
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

  Future<XFile?> takePicture(CameraController controller) async {
    try {
      return await controller.takePicture();
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
      return null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
