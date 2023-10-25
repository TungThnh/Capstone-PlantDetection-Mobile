//region imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:Detection/models/MIAMealModel.dart';
import 'package:Detection/providers/UserProvider.dart';
import 'package:Detection/screens/MIASplashScreen.dart';
import 'package:Detection/store/AppStore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Detection/store/MIAStore.dart';
import 'package:Detection/utils/AppTheme.dart';
import 'package:Detection/utils/MIAConstants.dart';
import 'package:Detection/utils/MIADataGenerator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

AppStore appStore = AppStore();

MIAStore miaStore = MIAStore();

List<MIAMealModel> mealMostPopularList = getMealList();
List<MIAMealModel> mealRecentlyCreatedList = getMealList();
List<MIAMealModel> mealTopRatedList = getMealList();
List<MIAMealModel> mealQuickEasyList = getMealList();

int currentIndex = 0;

void main() async {
  //region Entry Point
  WidgetsFlutterBinding.ensureInitialized();
  await initialize(aLocaleLanguageList: languageList());
  appStore.toggleDarkMode(value: getBoolAsync(isDarkModeOnPref));

  defaultRadius = 10;
  defaultToastGravityGlobal = ToastGravity.BOTTOM;
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
  //endregion
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '$appName${!isMobile ? ' ${platformName()}' : ''}',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          // Thêm các localization delegates tùy chỉnh nếu cần
        ],
        supportedLocales: [
          const Locale('en', 'US'), // Tiếng Anh (Mỹ)
          const Locale('vi', 'VN'), // Tiếng Việt (Việt Nam)
          // Thêm các ngôn ngữ và vùng khác nếu cần
        ],
        locale: const Locale('en', 'US'), // Ngôn ngữ mặc định
        home: MIASplashScreen(),
        theme: !appStore.isDarkModeOn
            ? AppThemeData.lightTheme
            : AppThemeData.darkTheme,
        navigatorKey: navigatorKey,
        scrollBehavior: SBehavior(),
        localeResolutionCallback: (locale, supportedLocales) => locale,


      ),
    );
  }
}
