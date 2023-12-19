import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Detection/models/HDUserModel.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../providers/APIUrl.dart';
import '../providers/UserProvider.dart';

class HDUpdateProfileScreen extends StatefulWidget {
  const HDUpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<HDUpdateProfileScreen> createState() => _HDUpdateProfileScreenState();
}

class _HDUpdateProfileScreenState extends State<HDUpdateProfileScreen> {
  HDUserModel? currenUser;

  late DateTime selectedDate;

  bool isFirstFetch = true;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController collegeController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dayOfBirthController;

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
  void initState() {
    super.initState();
    selectedDate =
        parseDate(currenUser?.dayOfBirth as String? ?? '') ?? DateTime.now();
    dayOfBirthController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final apiUrl = APIUrl.getUrl();
    final userProvider = Provider.of<UserProvider>(context);
    currenUser = userProvider.currentUser;

    firstNameController =
        TextEditingController(text: currenUser?.firstName ?? '');
    lastNameController =
        TextEditingController(text: currenUser?.lastName ?? '');
    collegeController = TextEditingController(text: currenUser?.college ?? '');
    phoneController = TextEditingController(text: currenUser?.phone ?? '');
    addressController = TextEditingController(text: currenUser?.address ?? '');

    if (isFirstFetch) {
      selectedDate =
          parseDate(currenUser?.dayOfBirth as String ?? '') ?? DateTime.now();
      dayOfBirthController = TextEditingController(
          text: DateFormat('dd/MM/yyyy').format(selectedDate) ?? '');
    }

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          isFirstFetch = false;
          selectedDate = picked;
          dayOfBirthController.text =
              DateFormat('dd/MM/yyyy').format(selectedDate) ?? '';
        });
      }
    }

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
            'Profile',
            style: TextStyle(
              color: Colors.black, // Màu chữ
              fontWeight: FontWeight.bold,
              fontSize: 24.0, // Kích thước chữ
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  // Điều chỉnh khoảng cách từ bên trái màn hình
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      //Thêm viền xung quanh TextFormField
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      // Điều chỉnh khoảng cách đỉnh và đáy
                      prefixIcon: Icon(
                          Icons.person), //Thêm biểu tượng trước trường nhập
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value.trim() == '') {
                        return 'First Name is required';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty || value.trim() == '') {
                        return 'Last Name is required';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty || value.trim() == '') {
                        return 'College is required';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone is required';
                      }
                      if (!isValidPhoneNumber(value)) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty || value.trim() == '') {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: TextFormField(
                    controller: dayOfBirthController,
                    readOnly: true,
                    // Đặt trạng thái chỉ đọc để không cho người dùng nhập trực tiếp
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Day Of Birth',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
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
                            Uri.parse(
                                apiUrl + '/api/students/${currenUser?.id}'),
                            headers: bearerHeaders,
                            body: jsonEncode(data),
                          );
                          // DateTime sd = DateTime.parse(dayOfBirthController.text);
                          // print(sd);
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
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.resolveWith(
                          (states) => Size(200, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Điều chỉnh giá trị theo ý muốn
                        ),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.black, // Đặt màu cho văn bản
                        fontSize: 24, // Đặt kích thước của văn bản (tuỳ chọn)
                        fontWeight: FontWeight
                            .bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime? parseDate(String inputDate) {
  try {
    // Định dạng chuỗi ngày theo định dạng "dd/MM/yyyy"
    DateFormat format = DateFormat('dd/MM/yyyy');
    // Chuyển đổi chuỗi ngày thành đối tượng DateTime
    DateTime parsedDate = format.parseStrict(inputDate);
    return parsedDate;
  } catch (e) {
    // Xử lý nếu có lỗi định dạng
    return null;
  }
}

bool isValidPhoneNumber(String phoneNumber) {
  // Sử dụng biểu thức chính quy để kiểm tra xem chuỗi có 10 chữ số không
  RegExp regExp = RegExp(r'^0(3[2-9]|5[6-8]|7[0-9]|8[1-6]|9[0-8])\d{7}$');
  return regExp.hasMatch(phoneNumber);
}
