import 'package:flutter/cupertino.dart';

class APIUrl extends ChangeNotifier {

  static const baseURL = 'https://f5cb-115-74-28-89.ngrok-free.app';

  static getUrl() {
    return baseURL;
  }
}
