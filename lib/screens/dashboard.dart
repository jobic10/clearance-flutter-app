import 'dart:convert';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String email = "";
  String name = "";
  Widget accountPicture = CircleAvatar(
    child: Text("O"),
  );

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString(constant.token);
    try {
      final response = await http.get(
        Uri.parse(constant.url + "student"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      dynamic res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          homeElements = <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 70,
              width: 80,
              child: CircleAvatar(
                backgroundImage:
                    NetworkImage("${Constants.domain}${res['picture']}"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(res['fullname']),
                subtitle: Text("Full Name"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.verified_user),
                title: Text(res['regno']),
                subtitle: Text("Matric. Number"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.backup),
                title: Text(res['gender']),
                subtitle: Text("Gender"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.school),
                title: Text(res['department']),
                subtitle: Text("Department"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.download_done_rounded),
                title: Text(res['cleared'] ? 'Cleared' : 'Uncleared Yet'),
                subtitle: Text("Clearance Status"),
              ),
            ),
          ];
          email = res['regno'];
          name = res['fullname'];
          accountPicture = CircleAvatar(
            backgroundImage:
                NetworkImage("${Constants.domain}${res['picture']}"),
          );
        });
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        pref.setString(constant.token, res['token'].toString());
        pref.setBool(constant.isLoggedin, true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Access Granted... Welcome!")));
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Alert(
              context: context,
              title: "Server Error",
              desc: "We could not connect to the server. App will close!",
              type: AlertType.error)
          .show();
      constant.exit();
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  var homeElements = <Widget>[
    Text(
      'Please wait while system loads your data!',
    ),
  ];
  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(constant.appName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: homeElements,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(email),
              accountName: Text(name),
              currentAccountPicture: accountPicture,
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('New Upload'),
              onTap: () {
                Navigator.pushNamed(context, '/upload');
              },
            ),
            ListTile(
              leading: Icon(Icons.ballot_rounded),
              title: Text('View Upload Status'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () async {
                // POP Screen
                // Clear Token from SharedPref
                Alert(
                        context: context,
                        title: "Please confirm",
                        desc: "You are about to be signed out",
                        buttons: [
                          DialogButton(
                              child: Text("Proceed"),
                              onPressed: () async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.remove(constant.token);
                                pref.remove(constant.isLoggedin);
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              }),
                          DialogButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                        type: AlertType.info)
                    .show();
              },
            ),
          ],
        ),
      ),
    );
  }
}
