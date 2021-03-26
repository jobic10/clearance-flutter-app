import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class Upload extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UploadState();
  }
}

class UploadState extends State<Upload> {
  String token = "";
  void _fetchDocs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString(constant.token);
    try {
      final response = await http.get(
        Uri.parse(constant.url + "docs"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);

        List<Map> docs = res != null ? List.from(res) : null;
        print(docs);
        List<DropdownMenuItem<dynamic>> s = [];
        for (var doc in docs) {
          print(doc);
          s.add(DropdownMenuItem(
            child: Text(doc['name']),
            value: doc['id'].toString(),
          ));
        }
        setState(() {
          dropDown = s;
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

  List<DropdownMenuItem> dropDown = [
    DropdownMenuItem(
      child: Text("Choose Document"),
      value: -1,
    ),
  ];
  String displayDocumentName = "";
  String documentName = "";
  String selectedDocument;
  String selectedDocumentExt = "";
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
                        'Make New Upload',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Which document do you want to upload',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Container(
                      child: DropdownButtonFormField(
                        items: dropDown,
                        onChanged: (val) {
                          selectedDocument = val;
                          print("Selected is $val");
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: RaisedButton(
                        child: Text("Select File"),
                        onPressed: () async {
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              // 'pdf',
                              // 'doc',
                              // 'docx',
                              // 'png',
                              'jpg',
                              'jpeg'
                            ],
                          );
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            setState(() {
                              documentName = file.path;
                              displayDocumentName = file.name;
                              selectedDocumentExt = file.extension;
                            });
                            // print(file.name);
                            // print(file.bytes);
                            // print(file.size);
                            // print(file.extension);
                            // print(file.path);
                          } else {
                            setState(() {
                              displayDocumentName = "";
                              documentName = "";
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        displayDocumentName,
                        style: TextStyle(color: Colors.pink, fontSize: 14.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: ButtonTheme(
                          minWidth: 120.0,
                          height: 50.0,
                          child: RaisedButton(
                            color: Colors.blue,
                            // onPressed: isClicked ? null : _login,
                            onPressed: () async {
                              if (documentName.isEmpty ||
                                  selectedDocumentExt.isEmpty) {
                                Alert(
                                        context: context,
                                        title: "Form Error",
                                        desc:
                                            "Please select file to upload to server!",
                                        buttons: [
                                          DialogButton(
                                              child: Text("Ok"),
                                              onPressed: () =>
                                                  Navigator.of(context).pop())
                                        ],
                                        type: AlertType.error)
                                    .show();
                                return;
                              }
                              if (selectedDocument.isEmpty) {
                                Alert(
                                        context: context,
                                        title: "Form Error",
                                        desc: "Please select from drop-down!",
                                        buttons: [
                                          DialogButton(
                                              child: Text("Ok"),
                                              onPressed: () =>
                                                  Navigator.of(context).pop())
                                        ],
                                        type: AlertType.error)
                                    .show();
                                return;
                              }
                              Map<String, String> headers = {
                                "Authorization": "Token $token"
                              };

                              var postUri =
                                  Uri.parse("${constant.url}docs/upload");
                              var request =
                                  new http.MultipartRequest("POST", postUri);
                              request.fields['document_id'] = selectedDocument;
                              request.headers.addAll(headers);

                              request.files.add(
                                await http.MultipartFile.fromPath(
                                  'file',
                                  documentName,
                                ),
                              );
                              request.send().then((response) async {
                                final respStr =
                                    await response.stream.bytesToString();
                                dynamic res = jsonDecode(respStr);
                                print(
                                    "Response code is ${response.statusCode}");
                                if (response.statusCode == 401) {
                                  await Alert(
                                          context: context,
                                          title: "Access Denied",
                                          desc: "Please re-login!",
                                          buttons: [
                                            DialogButton(
                                                child: Text("Ok"),
                                                onPressed: () =>
                                                    Navigator.of(context).pop())
                                          ],
                                          type: AlertType.error)
                                      .show();
                                  constant.exit();
                                } else if (response.statusCode == 400) {
                                  Alert(
                                          context: context,
                                          title: "Error",
                                          desc: res['msg'],
                                          buttons: [
                                            DialogButton(
                                                child: Text("Ok"),
                                                onPressed: () =>
                                                    Navigator.of(context).pop())
                                          ],
                                          type: AlertType.error)
                                      .show();
                                } else if (response.statusCode == 201) {
                                  Alert(
                                          context: context,
                                          title: "Success",
                                          desc: "Upload completed!",
                                          buttons: [
                                            DialogButton(
                                                child: Text("Ok"),
                                                onPressed: () =>
                                                    Navigator.of(context).pop())
                                          ],
                                          type: AlertType.success)
                                      .show();
                                  setState(() {
                                    documentName = "";
                                    displayDocumentName = "Upload successful!";
                                  });
                                } else {
                                  if (res['error']) {
                                    Alert(
                                            context: context,
                                            title: "Error",
                                            desc: res['msg'],
                                            buttons: [
                                              DialogButton(
                                                  child: Text("Ok"),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop())
                                            ],
                                            type: AlertType.error)
                                        .show();
                                  } else {
                                    Alert(
                                            context: context,
                                            title: "Success",
                                            desc: "Document has been uploaded",
                                            buttons: [
                                              DialogButton(
                                                  child: Text("Ok"),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop())
                                            ],
                                            type: AlertType.success)
                                        .show();
                                  }
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            child: Text(
                              'Upload File',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ),
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
