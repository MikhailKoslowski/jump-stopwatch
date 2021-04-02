# jump-stopwatch

A Flutter Stopwatch that stops automatically when it detects a jump or a fall through the accelerometer data.

## Description
I'm a rock climber and during the pandemic all nearby gyms and crags are closed. To keep my training up to date I had to resort to home training.
One of the metrics I'm using to assess my progress is "How much time can I dead hang from a bar?". To automate the measurement I made a flutter "smart" stopwatch that you start, place the phone on your pocket and it automatically stops when a fall is detected.
Features:
- Programmable countdown with sounds, between 0 and 5s. This is enough time to place the phone on the pocket and prepare to start the hang.
- Automatic stop when a fall is detected using the device's accelerometer with a programmable threshold between 0 and 20m/s².- Also works as a regular stopwatch.

## References:
- [Flutter](https://flutter.dev/)
- [Flutter sensors](https://pub.dev/packages/sensors)
