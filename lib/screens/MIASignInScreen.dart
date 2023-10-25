import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Detection/models/HDUserModel.dart';
import 'package:Detection/screens/MIADashboardScreen.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:Detection/utils/MIAWidgets.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import '../providers/UserProvider.dart';

class MIASignInScreen extends StatelessWidget {
  const MIASignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiUrl = 'https://f8fe-171-232-7-224.ngrok-free.app';
    var currentUser;

    return Scaffold(
      appBar: miaAppBar(context),
      body: Stack(
        children: [
          // Hình nền
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Nội dung chính (nút)
          Positioned(
            bottom: 48, // Điều chỉnh vị trí đáy cho nút
            left: 12,
            right: 12,
            child: Container(
              width: double.infinity, // Đặt width là 100%
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    showLoadingDialog(context);
                    final GoogleSignInAccount? googleSignInAccount =
                        await GoogleSignIn().signIn();

                    if (googleSignInAccount != null) {
                      final GoogleSignInAuthentication
                          googleSignInAuthentication =
                          await googleSignInAccount.authentication;
                      final AuthCredential credential =
                          GoogleAuthProvider.credential(
                        accessToken: googleSignInAuthentication.accessToken,
                        idToken: googleSignInAuthentication.idToken,
                      );
                      final UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithCredential(credential);

                      final User user = userCredential.user!;
                      final String? idToken = await user.getIdToken();
                      if (user != null) {
                        try {
                          Map<String, String> headers = {
                            'Content-Type': 'application/json-patch+json',
                          };

                          Map<String, dynamic> data = {'idToken': idToken};

                          var jsonBody = jsonEncode(data);

                          final response = await http.post(
                              Uri.parse(apiUrl + '/api/auth/google/student'),
                              headers: headers,
                              body: jsonBody);
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            // Xử lý dữ liệu JSON trả về từ API
                            final Map<String, dynamic> data =
                                json.decode(response.body);
                            final               userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            userProvider.accessToken = data['accessToken'];
                            try {
                              Map<String, String> bearerHeaders = {
                                'Content-Type': 'application/json-patch+json',
                                'Authorization': 'Bearer ${userProvider.accessToken}',};

                              final response = await http.get(
                                Uri.parse(apiUrl + '/api/students/information'),
                                headers: bearerHeaders,
                              );
                              final Map<String, dynamic> data =
                                  json.decode(response.body);
                              print(data);
                               currentUser = HDUserModel(
                                  id: data['id'] ?? '',
                                  firstName: data['firstName'] ?? '',
                                  lastName: data['lastName'] ?? '',
                                  email: data['email'] ?? '',
                                  avatarUrl: data['avatarUrl'] ?? '',
                                  college: data['college'] ?? '',
                                  phone: data['phone'] ?? '',
                                  address: data['address'] ?? '',
                                  dayOfBirth: data['dayOfBirth'] ?? '',
                                  status: data['status'] ?? 'inActive');
                              userProvider.setCurrentUser(currentUser);
                            } catch (e) {
                              hideLoadingDialog(context);
                            }
                            hideLoadingDialog(context);
                            MIADashboardScreen().launch(context);
                            _showLoginSuccessDialog(context, currentUser);
                          }
                        } catch (e) {
                          hideLoadingDialog(context);
                          print('Error: $e');
                        }
                      }
                    }
                  } catch (e) {
                    hideLoadingDialog(context);
                    print('Lỗi đăng nhập với Google: $e');
                  }
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48.0), // Điều chỉnh giá trị theo ý muốn
                    ),
                  ),
                ),
                icon: Image.asset(
                  './images/google.png',
                  width: 36,
                  height: 36,
                ),
                label: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.white, // Đặt màu cho văn bản
                    fontSize: 20, // Đặt kích thước của văn bản (tuỳ chọn)
                    fontWeight:
                        FontWeight.bold, // Đặt độ đậm của văn bản (tuỳ chọn)
                  ),
                ),
              ),
            ),
          ),
        ],

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        // Text('Sign In', style: boldTextStyle(size: 30)),
        // 16.height,
        // 16.height,
        // Text('Email address', style: boldTextStyle()),
        // 8.height,
        // Container(
        //   decoration: BoxDecoration(
        //       color: appStore.isDarkModeOn
        //           ? context.cardColor
        //           : miaContainerSecondaryColor,
        //       borderRadius: radius(8)),
        //   padding: EdgeInsets.symmetric(horizontal: 8),
        //   child: AppTextField(
        //     keyboardType: TextInputType.emailAddress,
        //     cursorColor: miaPrimaryColor,
        //     autoFocus: true,
        //     textFieldType: TextFieldType.EMAIL,
        //     decoration: InputDecoration(border: InputBorder.none),
        //   ),
        // ),
        // 16.height,
        // Text('Password', style: boldTextStyle()),
        // 8.height,
        // Container(
        //   decoration: BoxDecoration(
        //       color: appStore.isDarkModeOn
        //           ? context.cardColor
        //           : miaContainerSecondaryColor,
        //       borderRadius: radius(8)),
        //   padding: EdgeInsets.symmetric(horizontal: 8),
        //   child: AppTextField(
        //     cursorColor: miaPrimaryColor,
        //     autoFocus: true,
        //     textFieldType: TextFieldType.PASSWORD,
        //     decoration: InputDecoration(border: InputBorder.none),
        //   ),
        // ),
        // 30.height,
        // AppButton(
        //   width: context.width() - 32,
        //   color: miaPrimaryColor,
        //   text: 'Done',
        //   textStyle: boldTextStyle(color: white),
        //   onTap: () {
        //     MIADashboardScreen().launch(context);
        //   },
        // ),
        // 16.height,
        // 16.height,
        // RichText(
        //   text: TextSpan(
        //     text: 'By using Mealime you agree to our ',
        //     style: secondaryTextStyle(),
        //     children: const <TextSpan>[
        //       TextSpan(
        //           text: 'Terms',
        //           style: TextStyle(
        //               decoration: TextDecoration.underline,
        //               fontWeight: FontWeight.bold)),
        //     ],
        //   ),
        // ).center(),
        //   ],
        // ).paddingSymmetric(horizontal: 16),
      ),
    );
  }

  void _showLoginSuccessDialog(BuildContext context, HDUserModel currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome ${currentUser?.firstName} ${currentUser?.lastName}'),
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

}
