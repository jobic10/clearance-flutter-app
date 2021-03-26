import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var _validate = false;
  bool isClicked = false;
  void _login() async {
    setState(() {
      emailController.text.isEmpty && passwordController.text.isEmpty
          ? _validate = true
          : _validate = false;
    });

    if (_validate != true) {
      _setPreferences();
    }
  }

  void _setPreferences() async {
    if (isClicked) return;
    isClicked = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please wait while we verify"),
        duration: Duration(seconds: 60),
      ),
    );
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Now, we check the API
    try {
      final response = await http.post(Uri.parse(constant.url + "login"),
          body: {
            "username": emailController.text,
            "password": passwordController.text
          });
      dynamic res = jsonDecode(response.body);
      if (res['token'].toString().length < 6) {
        Alert(
                context: context,
                title: "Access Denied",
                desc: "Enter Valid Login Details",
                buttons: [
                  DialogButton(
                      child: Text("Ok"),
                      onPressed: () => Navigator.of(context).pop())
                ],
                type: AlertType.error)
            .show();
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
              desc: "We could not connect to the server. Try Again!",
              type: AlertType.error)
          .show();
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        isClicked = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            constant.appName,
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Image.asset("assets/images/logo.png"),
                      width: 80,
                      height: 80,
                    ),
                    Container(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Please provide email and password.',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Container(
                        child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey,
                        labelText: 'Email',
                        errorText: _validate == true ? 'Required' : null,
                      ),
                    )),
                    Container(
                        child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.grey,
                        labelText: 'Password',
                        errorText: _validate == true ? 'Required' : null,
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: ButtonTheme(
                          minWidth: 120.0,
                          height: 50.0,
                          child: RaisedButton(
                            color: Colors.blue,
                            onPressed: isClicked ? null : _login,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      child: Text(
                        'Only students registered by the administrator are granted access to use this application.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
