import 'package:flutter/cupertino.dart';

class APIUrl extends ChangeNotifier {

  static const baseURL = 'https://1c02-115-74-36-211.ngrok-free.app';

  static getUrl() {
    return baseURL;
  }
}
