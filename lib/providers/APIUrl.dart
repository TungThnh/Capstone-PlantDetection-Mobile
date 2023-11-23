import 'package:flutter/cupertino.dart';

class APIUrl extends ChangeNotifier {

  static const baseURL = 'https://d381-115-74-28-89.ngrok-free.app';

  static getUrl() {
    return baseURL;
  }
}
