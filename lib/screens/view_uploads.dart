import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ViewUpload extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ViewUploadState();
  }
}

class ViewUploadState extends State<ViewUpload> {
  String token = "";
  void _fetchDocs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString(constant.token);
    try {
      final response = await http.get(
        Uri.parse(constant.url + "upload/all"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        if (res['error']) {
          Alert(
                  context: context,
                  title: "Oops...",
                  desc: "You are yet to make any uploads",
                  buttons: [
                    DialogButton(
                        child: Text("Ok"),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                  type: AlertType.info)
              .show();
          return;
        }
        List<Map> uploads =
            res['uploads'] != null ? List.from(res['uploads']) : null;
        print(uploads);
        List<Widget> s = [];
        for (var doc in uploads) {
          print(doc);
          s.add(ListTile(
            leading: Icon(Icons.file_copy),
            title: Text(doc['document']),
            subtitle: doc['approved']
                ? Text("Approved")
                : doc['remark'] == null
                    ? Text("Yet to be reviewed")
                    : (Text(doc['remark']) == null
                        ? Text("Yet to be reviewed")
                        : Text(doc['remark'])),
            trailing: doc['approved']
                ? Icon(Icons.file_download_done)
                : Icon(Icons.pending),
          ));
        }
        setState(() {
          docs.addAll(s);
        });
      } else {
        await Alert(
                context: context,
                title: "Error",
                desc: "Server connection could not be established",
                buttons: [
                  DialogButton(
                      child: Text("Ok"),
                      onPressed: () => Navigator.of(context).pop())
                ],
                type: AlertType.error)
            .show();
        constant.exit();
      }
    } catch (error) {
      print(error);
      Alert(
              context: context,
              title: "Server Error",
              desc: "We could not connect to the server. Try Again!",
              type: AlertType.error)
          .show();
    }
  }

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    _fetchDocs();
  }

  @override
  List<Widget> docs = [
    Container(
      child: Image.asset("assets/images/logo.png"),
      width: 80,
      height: 80,
    ),
    Container(
      child: Text(
        'View Status Of Previously Upload Documents',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24.0),
      ),
    ),
  ];
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
                  children: docs,
                ),
              )),
        ),
      ),
    );
  }
}
