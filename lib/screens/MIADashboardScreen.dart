import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Detection/fragments/HDCameraFragment.dart';
import 'package:Detection/fragments/MIAFavFragment.dart';
import 'package:Detection/fragments/MIAGroceryFragment.dart';
import 'package:Detection/fragments/HDClassFragment.dart';
import 'package:Detection/fragments/MIASettingsFragment.dart';
import 'package:Detection/main.dart';
import 'package:Detection/models/MIADashboardModel.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:Detection/utils/MIADataGenerator.dart';
import 'package:nb_utils/nb_utils.dart';

class MIADashboardScreen extends StatefulWidget {

  const MIADashboardScreen({Key? key}) : super(key: key);


  @override
  _MIADashboardScreenState createState() => _MIADashboardScreenState();
}

class _MIADashboardScreenState extends State<MIADashboardScreen> {
  int selectedTab = 0;

  List<MIADashboardModel> fragmentList = getFragmentsList();

  Widget getFragment() {
    if (selectedTab == 0) {
      return HDClassFragment();
    } else if (selectedTab == 1) {
      return MIASettingsFragment();
    } else {
      return HDCameraFragment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getFragment(),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: boxDecorationDefault(borderRadius: radius(0), color: context.cardColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: fragmentList.map((e) {
              int index = fragmentList.indexOf(e);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(e.image,
                      height: 26,
                      width: 26,
                      fit: BoxFit.cover,
                      color: selectedTab == index
                          ? miaPrimaryColor
                          : appStore.isDarkModeOn
                              ? Colors.white54
                              : miaSecondaryColor),
                  Text(e.tab,
                      style: secondaryTextStyle(
                          color: selectedTab == index
                              ? miaPrimaryColor
                              : appStore.isDarkModeOn
                                  ? Colors.white54
                                  : miaSecondaryColor,
                          size: 12))
                ],
              ).onTap(() {
                selectedTab = index;
                setState(() {});
              });
            }).toList(),
          ),
        ));
  }
}
