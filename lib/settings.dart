import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Settings extends ChangeNotifier {
  double _threshold = 5;
  int _countdown = 3;

  NumberFormat _f = NumberFormat('##.00');

  get threshold => _threshold;
  get thresholdStr => _f.format(_threshold);
  set threshold(value) {
    _threshold = value;
    notifyListeners();
  }

  get countdown => _countdown;
  set countdown(value) {
    _countdown = value;
    notifyListeners();
  }
}