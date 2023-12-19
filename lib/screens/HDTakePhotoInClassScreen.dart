import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/MIAColors.dart';

class HDTakePhotoInClassScreen extends StatefulWidget {
  final CameraController controller;

  HDTakePhotoInClassScreen({required this.controller});

  @override
  _HDTakePhotoInClassScreenState createState() =>
      _HDTakePhotoInClassScreenState(controller: controller);
}

class _HDTakePhotoInClassScreenState extends State<HDTakePhotoInClassScreen> {
  final CameraController controller;
  late File? capturedImage = null;

  _HDTakePhotoInClassScreenState({required this.controller});

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
            icon: Icon(Icons.close, color: miaPrimaryColor),
            onPressed: () {
              setState(() {
                capturedImage = null;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (capturedImage != null)
              Image.file(
                capturedImage!,
                fit: BoxFit.contain,
                height: 600,
                width: double.infinity,
              )
            else
              CameraPreview(controller),
            (capturedImage != null)
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Gọi hàm crop ảnh tại đây
                        openImageCropper(capturedImage!.path ?? '');
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.resolveWith(
                            (states) => Size(80, 40)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildZoomButton(1.0, controller),
                      buildZoomButton(2.0, controller),
                      buildZoomButton(3.0, controller),
                      buildZoomButton(4.0, controller),
                      buildZoomButton(5.0, controller),
                      buildZoomButton(8.0, controller),
                    ],
                  ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      showLoadingDialog(context);
                      try {
                        final XFile? picture = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        hideLoadingDialog(context);
                        if (picture != null) {
                          File selectedImage = File(picture.path);
                          setState(() {
                            capturedImage = selectedImage;
                          });
                        }
                      } catch (e) {
                        print('Error picking image: $e');
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
                            Icons.collections,
                            size: 36.0,
                            color: Colors.white,
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      showLoadingDialog(context);
                      try {
                        final XFile? picture = await takePicture(controller);
                        hideLoadingDialog(context);
                        if (picture != null) {
                          File selectedImage = File(picture.path);
                          print('Captured image path: ${selectedImage.path}');
                          setState(() {
                            capturedImage = selectedImage;
                          });
                        }
                      } catch (e) {
                        print('Error capturing image: $e');
                      }
                    },
                    child: Container(
                      width: 68.0,
                      height: 68.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 36.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context, capturedImage?.path);
                    },
                    child: Container(
                      width: 68.0,
                      height: 68.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 36.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
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

  Future<XFile?> takePicture(CameraController controller) async {
    try {
      return await controller.takePicture();
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        capturedImage = croppedImage;
      });
    }
  }
}

Widget buildZoomButton(double zoomLevel, CameraController controller) {
  return GestureDetector(
    onTap: () {
      controller.setZoomLevel(zoomLevel);
    },
    child: Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        padding: EdgeInsets.only(top: 6, right: 6, left: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text('$zoomLevel x'),
      ),
    ),
  );
}
