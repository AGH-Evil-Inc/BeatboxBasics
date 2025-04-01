import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage ({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings',
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