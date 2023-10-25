import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Detection/models/HDUserModel.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../providers/UserProvider.dart';

class HDUpdateProfileScreen extends StatefulWidget {
  const HDUpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<HDUpdateProfileScreen> createState() => _HDUpdateProfileScreenState();
}

class _HDUpdateProfileScreenState extends State<HDUpdateProfileScreen> {
  HDUserModel? currenUser;

  void _showUpdateSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Success'),
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

  @override
  Widget build(BuildContext context) {
    final apiUrl = 'https://f8fe-171-232-7-224.ngrok-free.app';
    final userProvider = Provider.of<UserProvider>(context);
    currenUser = userProvider.currentUser;
    var firstNameController =
    TextEditingController(text: currenUser?.firstName ?? '');
    var lastNameController =
    TextEditingController(text: currenUser?.lastName ?? '');
    var collegeController =
    TextEditingController(text: currenUser?.college ?? '');
    var phoneController = TextEditingController(text: currenUser?.phone ?? '');
    var addressController =
    TextEditingController(text: currenUser?.address ?? '');
    var dayOfBirthController =
    TextEditingController(text: currenUser?.dayOfBirth ?? '');

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
            onPressed: () {
              finish(context);
            },
            child: Text('Cancel',
                style: primaryTextStyle(color: miaPrimaryColor))),
        leadingWidth: 80,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network('${currenUser?.avatarUrl}')
                  .cornerRadiusWithClipRRect(100)
                  .onTap(() {}),
              /*    Icon(Icons.account_circle_outlined, color: miaSecondaryColor, size: 100).onTap(() {
                  showSettingsBottomSheet(context);
                }).center(),*/
              16.height,
              Text('${currenUser?.email}',
                  style: boldTextStyle(color: miaSecondaryColor, size: 20)),
              20.height,
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0), // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(), //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0), // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon: Icon(Icons.person), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              SizedBox(height: 20.0), // Khoảng cách giữa các TextFormField
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: collegeController,
                  decoration: InputDecoration(
                    labelText: 'College',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    prefixIcon: Icon(Icons.school),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                // Điều chỉnh khoảng cách từ bên trái màn hình
                child: TextFormField(
                  controller: dayOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Day Of Birth',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    //Thêm viền xung quanh TextFormField
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    // Điều chỉnh khoảng cách đỉnh và đáy
                    prefixIcon: Icon(Icons
                        .calendar_today), //Thêm biểu tượng trước trường nhập
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Map<String, String> bearerHeaders = {
                      'Content-Type': 'application/json-patch+json',
                    };
                    final Map<String, dynamic> data = {
                      "firstName": "${firstNameController.text}",
                      "lastName": "${lastNameController.text}",
                      "avatarUrl": "${currenUser?.avatarUrl}",
                      "college": "${collegeController.text}",
                      "phone": "${phoneController.text}",
                      "address": "${addressController.text}",
                      "dayOfBirth": "${dayOfBirthController.text}"
                    };
                    final response = await http.put(
                      Uri.parse(apiUrl + '/api/students/${currenUser?.id}'),
                      headers: bearerHeaders,
                      body: jsonEncode(data),
                    );
                    print(response.statusCode);
                    if (response.statusCode == 200) {
                      _showUpdateSuccessDialog(context);
                      final Map<String, dynamic> responseData =
                      json.decode(response.body);

                      setState(() {
                        currenUser = HDUserModel(
                          id: responseData['id'] ?? '',
                          firstName: responseData['firstName'] ?? '',
                          lastName: responseData['lastName'] ?? '',
                          email: responseData['email'] ?? '',
                          avatarUrl: responseData['avatarUrl'] ?? '',
                          college: responseData['college'] ?? '',
                          phone: responseData['phone'] ?? '',
                          address: responseData['address'] ?? '',
                          dayOfBirth: responseData['dayOfBirth'] ?? '',
                          status: responseData['status'] ?? 'inActive',
                        );
                        userProvider.setCurrentUser(currenUser!);
                      });
                    }
                  } catch (e) {}
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0), // Điều chỉnh giá trị theo ý muốn
                    ),
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white, // Đặt màu cho văn bản
                    fontSize: 30, // Đặt kích thước của văn bản (tuỳ chọn)
                    fontWeight:
                    FontWeight.bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
