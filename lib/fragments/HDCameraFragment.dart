

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
      appBar: miaFragmentAppBar(context, 'Camera', false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 2, color: Colors.black),
          Padding(padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step 1: Allow camera access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                '   When you click the floating button below, the application will ask for your permission to access the camera, please agree to continue using it.', style: TextStyle( fontSize: 16),
              ),
              10.height,
              Text(
                'Step 2: Take the picture of the leaf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                '   Align the phone angle and try to determine it as clearly as possible so that the application gives the best results.', style: TextStyle( fontSize: 16),
              ),
              10.height,
              Text(
                'Step 3: Upload your picture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                '   Press the upload icon in the top right of the app bar to upload yoủ picture to the server.', style: TextStyle( fontSize: 16),
              ),
              10.height,
              Text(
                'Step 4: View the result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                '   If the returned result is identified with over 70% accuracy, the application will determine what tree it is and return a screen including all information of that tree.', style: TextStyle( fontSize: 16),
              ),
              Text(
                '   If the accuracy is not enough, the application will return a list of 5 plants that are most likely to resemble the sample.', style: TextStyle( fontSize: 16),
              ),
              Text(
                '  If the image is judged not to be a leaf, the application will return a malformed leaf result.', style: TextStyle( fontSize: 16),
              ),
            ],
          ),)
        ],
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




