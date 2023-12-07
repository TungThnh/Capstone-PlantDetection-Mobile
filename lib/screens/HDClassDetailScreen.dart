import 'dart:convert';

import 'package:Detection/fragments/HDClassFragment.dart';
import 'package:Detection/providers/APIUrl.dart';
import 'package:Detection/screens/HDDetectPlantInClassScreen.dart';
import 'package:Detection/screens/HDManageReportScreen.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Detection/models/HDUserModel.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../models/HDClassModel.dart';
import 'package:http/http.dart' as http;
import '../providers/UserProvider.dart';
import '../utils/MIAColors.dart';

class HDClassDetailScreen extends StatefulWidget {
  final HDClassModel classModel;

  HDClassDetailScreen({required this.classModel});

  @override
  State<HDClassDetailScreen> createState() => _HDClassDetailScreenState();
}

class _HDClassDetailScreenState extends State<HDClassDetailScreen> {
  HDClassModel? classModel;
  List<HDUserModel> studentList = [];
  bool hasFetchedData = false;
  bool isMember = false;
  bool isModelExists = false;
  final apiUrl = APIUrl.getUrl();

  @override
  void initState() {
    super.initState();
    classModel = widget.classModel;
    if (!hasFetchedData) {
      checkIsModelExists(apiUrl, classModel?.id);
      fetchMemberOfClass(apiUrl, classModel?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    var nameController =
        TextEditingController(text: classModel!.name ?? 'Name');
    var descriptionController =
        TextEditingController(text: classModel?.description ?? 'Description');
    var createAtController = TextEditingController(
      text: classModel?.createAt != null
          ? DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(classModel!.createAt))
          : 'CreateAt',
    );
    var numberOfMemberController = TextEditingController(
        text: classModel?.numberOfMember.toString() ?? '0');
    var managerController =
        TextEditingController(text: classModel?.manager.email ?? 'Manager');
    var codeController =
        TextEditingController(text: classModel?.code ?? 'Code');

    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    for (HDUserModel User in studentList) {
      if (User.id == currentUser?.id) {
        isMember = true;
        break; // Thoát khỏi vòng lặp khi tìm thấy sinh viên trùng ID
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ).paddingSymmetric(horizontal: 8),
        title: Padding(
          padding: EdgeInsets.only(left: 96),
          child: Text(
            'Details',
            style: TextStyle(
              color: Colors.black, // Màu chữ
              fontWeight: FontWeight.bold,
              fontSize: 24.0, // Kích thước chữ
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              20.height,
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
                      classModel?.thumbnailUrl ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              20.height,
              Container(
                width: double.infinity,
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: studentList.map((student) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                student.avatarUrl.toString()),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${student.firstName} ${student.lastName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Container(
                                    height: 85,
                                    child: Column(
                                      children: [
                                        Text('${student.email}' ?? 'email'),
                                        20.height,
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 8,
                                              bottom: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            color: (student.classStatus ==
                                                    'Pending Approval')
                                                ? Colors.yellow
                                                : Colors.green,
                                          ),
                                          child: Text(
                                              '${student.classStatus}' ??
                                                  'status'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Container(
                              height: 50,
                              width: 50,
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(student.avatarUrl.toString()),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  readOnly: true,
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Code',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon:
                        Icon(Icons.qr_code), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  readOnly: true,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon:
                        Icon(Icons.class_), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                    readOnly: true,
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      //Thêm viền xung quanh TextFormField
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      // Điều chỉnh khoảng cách đỉnh và đáy
                      prefixIcon: Icon(Icons
                          .description), //Thêm biểu tượng trước trường nhập
                    ),
                    maxLines: null),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  readOnly: true,
                  controller: createAtController,
                  decoration: InputDecoration(
                    labelText: 'Create At',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon: Icon(
                        Icons.lock_clock), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  readOnly: true,
                  controller: numberOfMemberController,
                  decoration: InputDecoration(
                    labelText: 'Max Of Members',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon:
                        Icon(Icons.person), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  readOnly: true,
                  controller: managerController,
                  decoration: InputDecoration(
                    labelText: 'Manager',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon: Icon(Icons
                        .manage_accounts), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              20.height,
              if (!isMember && hasFetchedData)
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 24),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            Map<String, String> bearerHeaders = {
                              'Content-Type': 'application/json-patch+json',
                              'Authorization':
                                  'Bearer ${userProvider.accessToken}',
                            };
                            final queryParameters = {
                              'classId': '${classModel?.id}',
                            };
                            final response = await http.post(
                                Uri.parse(
                                        apiUrl + '/api/classes/request-to-join')
                                    .replace(queryParameters: {
                                  'classId': classModel?.id,
                                }),
                                headers: bearerHeaders);
                            if (response.statusCode == 200) {
                              setState(() {
                                isMember = true;
                                hasFetchedData = false;
                                Navigator.pop(context, true);
                                _showRequestSuccessDialog(context);
                              });
                            } else if (response.statusCode == 423) {
                              Navigator.pop(context);
                              _showClassClosedDialog(context);
                            } else {}
                          } catch (e) {}
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.resolveWith(
                                  (states) => Size(200, 50)),
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
                              Icons.call_missed_outgoing,
                              color: Colors.black,
                            ),
                            10.width,
                            Text(
                              'Enroll',
                              style: TextStyle(
                                color: Colors.black,
                                // Đặt màu cho văn bản
                                fontSize: 18,
                                // Đặt kích thước của văn bản (tuỳ chọn)
                                fontWeight: FontWeight
                                    .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (hasFetchedData && isMember)
                if (classModel?.status == 'Opening')
                  Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 16, left: 16, right: 16),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HDManageReportScreen(
                                        classId: classModel!.id)),
                              );
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.resolveWith(
                                  (states) => Size(200, 50)),
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
                                  Icons.collections_bookmark,
                                  color: Colors.black,
                                ),
                                10.width,
                                Text(
                                  'Send data',
                                  style: TextStyle(
                                    color: Colors.black,
                                    // Đặt màu cho văn bản
                                    fontSize: 18,
                                    // Đặt kích thước của văn bản (tuỳ chọn)
                                    fontWeight: FontWeight
                                        .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              if (hasFetchedData && isMember)
                if (classModel?.status == 'Opening')
                  if (isModelExists)
                    Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 16, left: 16, right: 16),
                          child: Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final cameras = await availableCameras();
                                final camera = cameras.first;
                                CameraController _controller = CameraController(
                                    camera, ResolutionPreset.medium);
                                await _controller!.initialize();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HDDetectPlantInClassScreen(
                                            controller: _controller,
                                            classId: classModel!.id,
                                          )),
                                );
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.resolveWith(
                                    (states) => Size(200, 50)),
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
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  10.width,
                                  Text(
                                    'Detect',
                                    style: TextStyle(
                                      color: Colors.black,
                                      // Đặt màu cho văn bản
                                      fontSize: 18,
                                      // Đặt kích thước của văn bản (tuỳ chọn)
                                      fontWeight: FontWeight
                                          .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              if (hasFetchedData && isMember)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await LeaveClass(apiUrl, classModel!.id, userProvider.accessToken);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            minimumSize: MaterialStateProperty.resolveWith(
                                (states) => Size(200, 50)),
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
                                Icons.exit_to_app,
                                color: Colors.black,
                              ),
                              10.width,
                              Text(
                                'Leave class',
                                style: TextStyle(
                                  color: Colors.black,
                                  // Đặt màu cho văn bản
                                  fontSize: 18,
                                  // Đặt kích thước của văn bản (tuỳ chọn)
                                  fontWeight: FontWeight
                                      .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchMemberOfClass(String apiUrl, classId) async {
    if (!studentList.isEmpty) {
      studentList = [];
    }
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
      };

      final response = await http.get(
          Uri.parse(apiUrl + '/api/classes/$classId/students'),
          headers: bearerHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> dataList = jsonMap['data'];
        List<HDUserModel> userList = [];
        dataList.forEach((userData) {
          final studentData = userData['student'];
          HDUserModel user = HDUserModel.fromJson(studentData);
          user.classStatus = userData['status'];
          userList.add(user);
        });
        setState(() {
          studentList = userList;
          hasFetchedData = true;
        });
      } else {
        setState(() {});
      }
    } catch (e) {}
  }

  Future<void> checkIsModelExists(String apiUrl, classId) async {
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
      };

      final response = await http.get(
          Uri.parse(apiUrl + '/api/classes/$classId/is-model-exists'),
          headers: bearerHeaders);

      if (response.statusCode == 200) {
        if (response.body == "true") {
          setState(() {
            isModelExists = true;
          });
        }
      } else {
        setState(() {
          isModelExists = false;
        });
      }
    } catch (e) {}
  }

  Future<void> LeaveClass(String apiUrl, classId, accessToken) async {
    try {
      Map<String, String> bearerHeaders = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': 'Bearer $accessToken',
      };

      bool? leaveClass = await showLeaveClassConfirmationDialog(context);
      if (leaveClass == true) {
        final response = await http.delete(
            Uri.parse(apiUrl + '/api/classes/$classId/leave'),
            headers: bearerHeaders);
        if (response.statusCode == 204) {
          Navigator.pop(context, true);
          _showLeaveClassSuccessDialog(context);// Leave Class
        } else {
          print('can not leave');
        }
      } else {
      }
    } catch (e) {
    }
  }

  void _showRequestSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Joining class success'),
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

  void _showLeaveClassSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave class success'),
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

  void _showClassClosedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('The class has been closed!'),
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

  Future<bool?> showLeaveClassConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Leave Class"),
          content: Text("Are you sure you want to leave this class?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); //
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
