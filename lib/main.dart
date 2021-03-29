import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Stopwatch with fall detection')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // StopWatch
  final stopWatch = Stopwatch();
  Timer? refreshTimer;

  // Countdown timer
  int countdown = 3;
  bool countingDown = false;
  bool transparent = true;
  int animationDuration = 250;

  // Sound fx
  static AudioCache sounds = AudioCache();
  final _440 = '440.wav';
  final _880 = '880.wav';
  late Uint8List _440_bytes;
  late Uint8List _880_bytes;

  // accelerometer
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  double acceleration = 0.0;
  final double gravity = 9.6;
  double threshold = 10.0;
  double maxAccel = 0.0;
  final twoDigitsDouble = NumberFormat('00.00');

  void loadSounds() async {
    //await sounds.loadAll([_440, _880]);
    _440_bytes = (await sounds.load(_440)).readAsBytesSync();
    _880_bytes = (await sounds.load(_880)).readAsBytesSync();
  }

  @override
  void initState() {
    super.initState();
    loadSounds();
    //accelerometerEvents.listen(accelerometerCallback);
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent data) {
      //acceleration = sqrt(data.x * data.x + data.y * data.y + data.z * data.z) - gravity;
      acceleration = max(max(data.x.abs(), data.y.abs()), data.z.abs()) - gravity;

      if (acceleration > threshold && stopWatch.isRunning) {
        sounds.playBytes(_440_bytes);
        stop();
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void animateCountdown() {
    setState(() {
      sounds.playBytes(countdown > 0 ? _440_bytes : _880_bytes);
      animationDuration = 100;
      transparent = false;
    });
    Future.delayed(Duration(milliseconds: animationDuration), () {
      setState(() {
        animationDuration = 650;
        transparent = true;
      });
    });
  }

  void runCountdown() async {
    countdown--;
    animateCountdown();
    if (countdown > 0) {
      refreshTimer = Timer(Duration(seconds: 1), runCountdown);
    } else {
      countingDown = false;
      stopWatch.start();
      refreshTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {}); // redraw stopwatch
      });
    }
  }

  void start() {
    countingDown = true;
    countdown = 3;
    stopWatch.reset();
    animateCountdown();
    refreshTimer = Timer(Duration(seconds: 1), runCountdown);
  }

  void stop() {
    setState(() {
      countingDown = false;
      stopWatch.stop();
      refreshTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            /*Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              //style: Theme.of(context).textTheme.headline4,
            ),*/

            //Text(
            //  'Current acceleration: ${twoDigitsDouble.format(acceleration)}',
            //  style: Theme.of(context).textTheme.headline5,
            //),
            Text(
              'Threshold for stop: ${twoDigitsDouble.format(threshold)} m/s²',
              style: Theme.of(context).textTheme.headline5,
            ),
            Slider(
              value: threshold,
              min: 0.0,
              max: 20.0,
              label: threshold.toString(),
              onChanged: (value) {
                setState(() {
                  threshold = value;
                });
              },
            ),
            //Text('$acceleration'),
            AnimatedDefaultTextStyle(
                child: Text(countdown.toString()),
                style: transparent
                    ? TextStyle(
                        color: Colors.transparent,
                        fontSize:
                            Theme.of(context).textTheme.headline1?.fontSize,
                      )
                    : TextStyle(
                        color: Colors.black,
                        fontSize:
                            Theme.of(context).textTheme.headline1?.fontSize,
                      ),
                duration: Duration(milliseconds: animationDuration)),
            Text(
              '${stopWatch.elapsed}',
              style: Theme.of(context).textTheme.headline5,
            ),
            IconButton(onPressed: () {
              if (!stopWatch.isRunning && !countingDown) {
                start();
              } else {
                stop();
              }
            },
              icon: Icon(stopWatch.isRunning || countingDown
                  ? Icons.pause
                  : Icons.play_arrow),)
          ],
        ),
      );
  }
}
