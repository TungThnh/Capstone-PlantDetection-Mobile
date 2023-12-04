import 'package:flutter/cupertino.dart';

class APIUrl extends ChangeNotifier {

  static const baseURL = 'https://21ef-115-74-24-148.ngrok-free.app';

  static getUrl() {
    return baseURL;
  }
}
