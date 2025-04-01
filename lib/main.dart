import 'package:app/data/notifiers.dart';
import 'package:app/views/widget_tree.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: isLightModeNotifier, builder:(context, isLightMode, child) {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,
        brightness: isLightMode ? Brightness.light : Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
    }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return WidgetTree();
  }
}
