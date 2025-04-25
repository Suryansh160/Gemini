import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '/consts.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API__KEY);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
