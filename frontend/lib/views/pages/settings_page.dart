import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage ({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String response = 'Settings Page';
  late String url  ="";

  Future<void> getData() async {
    if(Platform.isAndroid || Platform.isIOS) {
      url = "https://192.168.218.107:5001/api/test";
    } else if(Platform.isWindows) {
      url = "https://localhost:5001/api/test";
    } 

    try{
      final ioc = HttpClient();
      ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          this.response = response.body;
        });
      } else {
        setState(() {
          this.response = "Error: ${response.statusCode}";
        });
      }
    }
    catch (e) {
      print("Error: $e");
    } 
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings",
          style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.lightBlueAccent : Colors.blue,
          shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.0), 
                ),
              ),
        ),
      ),
    );
  }
}