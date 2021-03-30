import 'package:flutter/material.dart';

import 'stopwatch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jump Stopwatch',
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(title: Text('Jump Stopwatch')),
        body: MyStopWatch(),
      ),
    );
  }
}