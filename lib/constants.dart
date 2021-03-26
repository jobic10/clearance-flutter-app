import 'package:flutter/services.dart';

class Constants {
  final String isLoggedin = 'IS_LOGGED_IN';
  final String token = '';
  final String appName = "Penultimate Clearance App";
  static String domain = "http://192.168.43.180:8000";
  final String url = "${Constants.domain}/api/";
  void exit() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

final constant = Constants();
