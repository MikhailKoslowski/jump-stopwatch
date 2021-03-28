import 'dart:async';
import 'package:flutter/material.dart';

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
      home: MyHomePage(title: 'Stopwatch with fall detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = ''}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stopWatch = Stopwatch();
  Timer? refreshTimer;
  int countdown = 3;
  bool countingDown = false;
  bool transparent = true;
  int animationDuration = 250;


  void animateCountdown() {
    setState(() {
      animationDuration = 50;
      transparent = false;
    });
    Future.delayed(Duration(milliseconds: animationDuration), () {
      setState(() {
        animationDuration = 900;
        transparent = true;
      });
    });
  }

  void runCountdown() {
    countdown--;
    animateCountdown();
    if (countdown > 0) {
      refreshTimer = Timer(Duration(seconds: 1), runCountdown);
    } else {
      countingDown = false;
      stopWatch.start();
      refreshTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              //style: Theme.of(context).textTheme.headline4,
            ),*/
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
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!stopWatch.isRunning && !countingDown) {
            countingDown = true;
            countdown = 5;
            stopWatch.reset();
            animateCountdown();
            refreshTimer = Timer(Duration(seconds: 1), runCountdown);
          } else {
            setState(() {
              countingDown = false;
              stopWatch.stop();
              refreshTimer?.cancel();
            });
          }
        },
        tooltip: 'Increment',
        child: Icon(stopWatch.isRunning || countingDown ? Icons.pause : Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
