import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'stopwatch.dart';
import 'physics.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Physics()),
      ],
      child: MaterialApp(
        title: 'Jump StopWatch',
        theme: ThemeData(),
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/settings': (context) => MySettings(),
        },
      )));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jump Stopwatch'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: MyStopWatch(),
    );
  }
}

class MySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final physics = Provider.of<Physics>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: ListView(children: [
          ListTile(
            title: Text('Stop Threshold'),
            subtitle: Text('Gravity is already discounted'),
            leading: Icon(Icons.arrow_downward),
            trailing: Text('${physics.thresholdStr} m/s²'),
          ),
          ListTile(
            title: Slider(
              value: physics.threshold,
              label: physics.thresholdStr,
              min: 1,
              max: 20,
              onChanged: (value) {
                physics.threshold = value;
              },
            ),
          )
        ]),
      ),
    );
  }
}
