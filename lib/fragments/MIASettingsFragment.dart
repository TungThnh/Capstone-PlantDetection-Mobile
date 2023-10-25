import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Detection/utils/MIABottomSheets.dart';
import 'package:Detection/utils/MIAConstants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/MIADashboardModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/UserProvider.dart';
import '../screens/MIASignInScreen.dart';
import '../screens/HDUpdateProfileScreen.dart';
import '../utils/MIAColors.dart';
import '../utils/MIADataGenerator.dart';

class MIASettingsFragment extends StatefulWidget {
  const MIASettingsFragment({Key? key}) : super(key: key);

  @override
  State<MIASettingsFragment> createState() => _MIASettingsFragmentState();
}

class _MIASettingsFragmentState extends State<MIASettingsFragment> {
  List<MIADashboardModel> settingList = getSettingsList();

  @override
  void initState() {
    setStatusBarColor(appStore.scaffoldBackground!);
    super.initState();
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.scaffoldBackground!);
    super.dispose();
  }

  void _showLogoutSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out Success'),
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
    final userProvider = Provider.of<UserProvider>(context);
    final currenUser = userProvider.currentUser;
    return Observer(builder: (context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              70.height,
              Image.network('${currenUser?.avatarUrl}')
                  .cornerRadiusWithClipRRect(100),
              /*    Icon(Icons.account_circle_outlined, color: miaSecondaryColor, size: 100).onTap(() {
                  showSettingsBottomSheet(context);
                }).center(),*/
              16.height,
              Text('${currenUser?.email}',
                  style: boldTextStyle(color: miaSecondaryColor, size: 20)),
              20.height,
              // Divider(),
              // Container(
              //   decoration: BoxDecoration(
              //       color: miaPrimaryColor.withAlpha(30),
              //       borderRadius: radius(miaDefaultRadius)),
              //   padding: EdgeInsets.all(12),
              //   margin: EdgeInsets.all(16),
              //   child: Row(
              //     children: [
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('Upgrade to Pro',
              //               style: boldTextStyle(
              //                   color: miaPrimaryColor, size: 24)),
              //           8.height,
              //           Text(
              //               'Get exclusive recipes, nutritional information, advanced filters, and more.',
              //               style: secondaryTextStyle(color: miaPrimaryColor)),
              //         ],
              //       ).expand(),
              //       Icon(Icons.arrow_forward_ios, color: miaSecondaryTextColor)
              //     ],
              //   ),
              // ).onTap(() {
              //   MIAUpgradeScreen().launch(context);
              // }),
              // Row(
              //   children: [
              //     Container(
              //       height: 48,
              //       width: 48,
              //       decoration: BoxDecoration(
              //           color: miaPrimaryColor.withAlpha(30),
              //           borderRadius: radius(100)),
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text('1', style: boldTextStyle(color: miaPrimaryColor)),
              //           Text('lb',
              //               style: secondaryTextStyle(color: miaPrimaryColor)),
              //         ],
              //       ),
              //     ),
              //     8.width,
              //     Text('Food Waste Savings', style: boldTextStyle())
              //   ],
              // ).paddingSymmetric(horizontal: 16, vertical: 8),
              // Divider(),
              Row(
                children: [
                  appStore.isDarkModeOn
                      ? Icon(Icons.brightness_2,
                          color: context.iconColor, size: 30)
                      : Icon(Icons.wb_sunny_rounded,
                          color: context.iconColor, size: 30),
                  16.width,
                  Text('Choose App Theme', style: boldTextStyle()).expand(),
                  Switch(
                    value: appStore.isDarkModeOn,
                    activeTrackColor: miaPrimaryColor,
                    activeColor: Colors.grey,
                    inactiveThumbColor: miaPrimaryColor,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (val) async {
                      appStore.toggleDarkMode(value: val);
                      await setValue(isDarkModeOnPref, val);
                    },
                  ),
                ],
              )
                  .paddingOnly(left: 16, top: 8, right: 16, bottom: 8)
                  .onTap(() async {
                if (getBoolAsync(isDarkModeOnPref)) {
                  appStore.toggleDarkMode(value: false);
                  await setValue(isDarkModeOnPref, false);
                } else {
                  appStore.toggleDarkMode(value: true);
                  await setValue(isDarkModeOnPref, true);
                }
              }),
              Divider(),
              InkWell(
                onTap: () async {
                  HDUpdateProfileScreen().launch(context);
                },
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(borderRadius: radius(100)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: context.iconColor, size: 30)
                        ],
                      ),
                    ),
                    8.width,
                    Text('Update Profile', style: boldTextStyle())
                  ],
                ).paddingSymmetric(horizontal: 8, vertical: 8),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                  userProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MIASignInScreen()),
                  );
                  _showLogoutSuccessDialog(context);
                },
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(borderRadius: radius(100)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: context.iconColor, size: 30)
                        ],
                      ),
                    ),
                    8.width,
                    Text('Log Out', style: boldTextStyle())
                  ],
                ).paddingSymmetric(horizontal: 8, vertical: 8),
              ),
              Divider(),
            ],
          ),
        ),
      );
    });
  }
}
