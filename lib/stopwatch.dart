import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'dart:typed_data';

import 'package:sensors/sensors.dart';
import 'dart:math';

import 'settings.dart';
import 'package:provider/provider.dart';

class MyStopWatch extends StatefulWidget {
  @override
  _MyStopWatchState createState() => _MyStopWatchState();
}

class _MyStopWatchState extends State<MyStopWatch> {
  int _minutes = 0;
  int _seconds = 0;
  int _milliseconds = 0;

  bool _running = false;
  int _countdownValue = 0;

  Timer? _timer;

  Stopwatch _stopwatch = Stopwatch();

  // Sound fx
  static AudioCache sounds = AudioCache();
  final _lowPitchFile = '440.wav';
  final _highPitchFile = '880.wav';
  late Uint8List _lowPitchBytes;
  late Uint8List _highPitchBytes;

  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  double acceleration = 0;
  double _threshold = 10;

  @override
  void initState() {
    loadSounds();
    _streamSubscriptions.add(userAccelerometerEvents.listen(accelerometerCallback));
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscriptions.forEach((streamSub) {
      streamSub.cancel();
    });
    sounds.clearCache();
    super.dispose();
  }

  void accelerometerCallback(UserAccelerometerEvent data) {
    acceleration = sqrt(data.x * data.x + data.y * data.y + data.z * data.z);

    if (acceleration > _threshold && _stopwatch.isRunning) {
      setState(() {
        stop();
      });
      sounds.playBytes(_lowPitchBytes);
    }
  }

  void loadSounds() async {
    _lowPitchBytes = (await sounds.load(_lowPitchFile)).readAsBytesSync();
    _highPitchBytes = (await sounds.load(_highPitchFile)).readAsBytesSync();
  }

  void _countdown({int value = 3}) {
    setState(() {
      _countdownValue = value;
    });

    if (value == 0) {
      sounds.playBytes(_highPitchBytes);
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        final int elapsed = _stopwatch.elapsed.inMilliseconds;
        setState(() {
          _milliseconds = elapsed % 1000;
          _seconds = (elapsed / 1000).floor() % 60;
          _minutes = ((elapsed / 1000).floor() / 60).floor();
        });
      });
      return;
    }
    sounds.playBytes(_lowPitchBytes);
    _timer = Timer(Duration(seconds: 1), () {
      _countdown(value: value - 1);
    });
  }

  String formatTime() {
    final f = NumberFormat('#00');
    return '${f.format(_minutes)}:${f.format(_seconds)}:${f.format((_milliseconds / 10).floor())}';
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _countdownValue = 0;
    _stopwatch.stop();
  }

  void start() {
    _running = true;
    final settings = Provider.of<Settings>(context, listen:false);
    _threshold = settings.threshold;
    _countdown(value: settings.countdown);
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _minutes = 0;
    _seconds = 0;
    _milliseconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text('$_countdownValue',
              style: _countdownValue == 0
                  ? TextStyle(color: Colors.transparent)
                  : Theme.of(context).textTheme.headline1),
        ),
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Text(formatTime(),
                style: Theme.of(context).textTheme.headline1)),
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: TextButton(
              onLongPress: () {
                setState(() {
                  reset();
                });
              },
              onPressed: () {
                setState(() {
                  if (_running) {
                    stop();
                  } else {
                    start();
                  }
                });
              },
              child: Text(
                _running ? 'STOP' : 'START / RESET',
                style: Theme.of(context).textTheme.headline2,
              ),
            ))
      ]),
    );
  }
}