import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'dart:typed_data';

import 'package:sensors/sensors.dart';
import 'dart:math';

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
  final double gravity = 9.6;
  final double threshold = 10;

  @override
  void initState() {
    loadSounds();

    //accelerometerEvents.listen(accelerometerCallback);
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent data) {
      //acceleration = sqrt(data.x * data.x + data.y * data.y + data.z * data.z) - gravity;
      acceleration =
          max(max(data.x.abs(), data.y.abs()), data.z.abs()) - gravity;

      if (acceleration > threshold && _stopwatch.isRunning) {
        setState(() {
          stop();
        });
        sounds.playBytes(_lowPitchBytes);
      }
    }));

    super.initState();
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
    _countdown(value: 5);
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

/*

class MyStopWatch extends StatefulWidget {
  @override
  _MyStopWatchState createState() => _MyStopWatchState();

}

class _MyStopWatchState extends State<MyStopWatch> {
  // StopWatch
  final _stopWatch = Stopwatch();
  Timer? _refreshTimer;

  // Countdown timer
  int _countdown = 3;
  bool _countingDown = false;
  bool _transparent = true;
  int _animationDuration = 250;

  int get countdown => _countdown;

  bool get running => _countingDown || _stopWatch.isRunning;

  void animateCountdown() {
    //sounds.playBytes(countdown > 0 ? _440_bytes : _880_bytes);
    setState(() {
      _animationDuration = 100;
      _transparent = false;
    });

    Future.delayed(Duration(milliseconds: _animationDuration), () {
      setState(() {
        _animationDuration = 650;
        _transparent = true;
      });
    });
  }

  void runCountdown() async {
    _countdown--;
    animateCountdown();
    if (_countdown > 0) {
      _refreshTimer = Timer(Duration(seconds: 1), runCountdown);
    } else {
      _countingDown = false;
      _stopWatch.start();
      _refreshTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          // timer updated.
        });
      });
    }
  }

  void start() {
    _countdown = 6;
    _stopWatch.reset();
    _refreshTimer = Timer(Duration(seconds: 1), runCountdown);
    setState(() {
      _countingDown = true;
    });
  }

  void stop() {
    _stopWatch.stop();
    _refreshTimer?.cancel();
    setState(() {
      _countingDown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedDefaultTextStyle(
          child: Text(countdown.toString()),
          style: _transparent
              ? TextStyle(
                  color: Colors.transparent,
                  fontSize: Theme.of(context).textTheme.headline1?.fontSize,
                )
              : TextStyle(
                  color: Colors.black,
                  fontSize: Theme.of(context).textTheme.headline1?.fontSize,
                ),
          duration: Duration(milliseconds: _animationDuration)),
      Text(
        '${_stopWatch.elapsed}',
        style: Theme.of(context).textTheme.headline5,
      ),
    ]);
  }
}
*/
