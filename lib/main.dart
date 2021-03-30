import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'stopwatch.dart';
import 'settings.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Settings()),
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

    final settings = Provider.of<Settings>(context, listen:true);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: ListView(children: [
          ListTile(
            title: Text('Stop Threshold'),
            subtitle: Text('Gravity is already discounted'),
            leading: Icon(Icons.arrow_downward),
            trailing: Text('${settings.thresholdStr} m/s²'),
          ),
          ListTile(
            title: Slider(
              value: settings.threshold,
              label: settings.thresholdStr,
              min: 0,
              max: 20,
              divisions: 40,
              onChanged: (value) {
                settings.threshold = value;
              },
            ),
          ),
          ListTile(
            title: Text('Countdown'),
            subtitle: Text('Number of beeps before starting'),
            leading: Icon(Icons.audiotrack),
            trailing: Text('${settings.countdown}'),
          ),
          ListTile(
            title: Slider(
              value: settings.countdown * 1.0,
              label: '${settings.countdown}',
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (value) {
                settings.countdown = value.toInt();
              },
            ),
          ),
        ]),
      ),
    );
  }
}
