import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../models/HDUserModel.dart';

class UserProvider extends ChangeNotifier {
  HDUserModel? _currentUser;

  HDUserModel? get currentUser => _currentUser;

  String? _accessToken;

  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  String? get accessToken => _accessToken;

  // Setter để cập nhật accessToken và thông báo sự thay đổi đến các người nghe
  set accessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  void setCurrentUser(HDUserModel user) {
    _currentUser = user;
  }
  void logout() {
    _currentUser = null;
  }
}