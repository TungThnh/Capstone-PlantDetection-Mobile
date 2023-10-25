

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/HDTakePhotoScreen.dart';
import '../utils/MIAColors.dart';
import '../utils/MIAWidgets.dart';


class HDCameraFragment extends StatefulWidget {
  @override
  const HDCameraFragment({Key? key}) : super(key: key);

  @override
  State<HDCameraFragment> createState() => _HDCameraFragmentState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}


class _HDCameraFragmentState extends State<HDCameraFragment> {
  @override
  Widget build(BuildContext context) {
    Future<void> openCamera() async {
      // Xin quyền truy cập camera
      final status = await Permission.camera.request();
      if (status.isGranted) {
        // Lấy danh sách các camera có sẵn trên thiết bị
        final cameras = await availableCameras();
        // Chọn một trong số các camera
        final camera = cameras.first;

        // Tạo đối tượng CameraController và khởi tạo camera
        final controller = CameraController(camera, ResolutionPreset.medium);
        await controller.initialize();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HDTakePhotoScreen(controller: controller),
          ),
        );
      } else {

      }
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await openCamera();
        },
        backgroundColor: miaPrimaryColor,
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );

  }
}




