import 'package:flutter/material.dart';
import 'package:Detection/main.dart';
import 'package:Detection/models/MIASelectOptionsModel.dart';
import 'package:Detection/screens/MIADislikesScreen.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:Detection/utils/MIAConstants.dart';
import 'package:Detection/utils/MIADataGenerator.dart';
import 'package:Detection/utils/MIAWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class MIAAllergiesScreen extends StatefulWidget {
  const MIAAllergiesScreen({Key? key}) : super(key: key);

  @override
  _MIAAllergiesScreenState createState() => _MIAAllergiesScreenState();
}

class _MIAAllergiesScreenState extends State<MIAAllergiesScreen> {
  List<MIASelectOptionsModel> allergyList = [];

  @override
  void initState() {
    allergyList = getAllergiesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: miaAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Any Allergies?', style: boldTextStyle(size: 30)),
              20.height,
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergyList.map((e) {
                    int index = allergyList.indexOf(e);
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: e.selected!
                              ? miaContainerColor
                              : appStore.isDarkModeOn
                                  ? context.cardColor
                                  : miaContainerSecondaryColor,
                          borderRadius: radius(miaDefaultRadius)),
                      child: Text(e.title,
                          style: boldTextStyle(
                              color: appStore.isDarkModeOn
                                  ? e.selected!
                                      ? Colors.black
                                      : Colors.white
                                  : Colors.black)),
                    ).onTap(() {
                      e.selected = !e.selected!;
                      setState(() {});
                    }, borderRadius: radius(miaDefaultRadius));
                  }).toList()),
            ],
          ),
          AppButton(
            color: miaPrimaryColor,
            text: 'Continue',
            textStyle: boldTextStyle(color: white),
            onTap: () {
              MIADislikesScreen().launch(context);
            },
          ).center().paddingBottom(20),
        ],
      ).paddingSymmetric(horizontal: 16),
    );
  }
}
