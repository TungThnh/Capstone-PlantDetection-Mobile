import 'package:flutter/material.dart';
import 'package:Detection/screens/MIASignInScreen.dart';
import 'package:Detection/screens/MIAWalkThroughScreen.dart';
import 'package:Detection/utils/MIAColors.dart';
import 'package:nb_utils/nb_utils.dart';

class MIAWelcomeScreen extends StatelessWidget {
  const MIAWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Align(
            alignment: Alignment.center,
            child: Image.asset('images/mealime.png', height: 150),
          ),
          Column(
            children: [
              16.height,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member?  ', style: secondaryTextStyle(size: 16, color: miaSecondaryTextColor)),
                  AppButton(
                    color: miaPrimaryColor,
                    text: 'Sign In',
                    textStyle: boldTextStyle(color: white),
                    onTap: () {
                      MIASignInScreen().launch(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ).paddingAll(20),
    );
  }
}
