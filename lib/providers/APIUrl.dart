import 'package:flutter/cupertino.dart';

class APIUrl extends ChangeNotifier {

  static const baseURL = 'https://0c1b-115-74-36-211.ngrok-free.app';

  static getUrl() {
    return baseURL;
  }
}
