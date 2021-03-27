import 'package:clearance/screens/dashboard.dart';
import 'package:clearance/screens/upload.dart';
import 'package:clearance/screens/view_uploads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
// import 'screens/home.dart';
import 'screens/login.dart';

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainAppState();
  }
}

class MainAppState extends State<MainApp> {
  var isLogin;
  void _checkPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLogin = pref.getBool(constant.isLoggedin);
    });
  }

  @override
  void initState() {
    _checkPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => isLogin == true ? HomePage() : Login(),
        '/dashboard': (context) => HomePage(),
        '/login': (context) => Login(),
        '/upload': (context) => Upload(),
        '/home': (context) => HomePage(),
        '/view': (context) => ViewUpload(),
      },
    );
  }
}
