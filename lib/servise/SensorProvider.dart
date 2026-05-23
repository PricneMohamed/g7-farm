import 'package:flutter/material.dart';

class SensorProvider extends ChangeNotifier {
  double temp;
  double humidity;
  int gas;
  int soil;
  int ultra;

  SensorProvider({
    this.temp = 0.0,
    this.humidity = 0.0,
    this.gas = 0,
    this.soil = 0,
    this.ultra = 0,
  });

  void updateData(double t, double h, int g, int s, int u) {
    temp = t;
    humidity = h;
    gas = g;
    soil = s;
    ultra = u;
    notifyListeners();
  }
}
