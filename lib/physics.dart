import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Physics extends ChangeNotifier {
  double _threshold = 10;

  NumberFormat _f = NumberFormat('##.00');

  get threshold => _threshold;
  get thresholdStr => _f.format(_threshold);
  set threshold(value) {
    _threshold = value;
    notifyListeners();
  }
}