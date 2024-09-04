import 'package:flutter/material.dart';
import 'package:parking_app/parking_map.dart';

void main() {
  runApp(ParkingApp());
}

class ParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParkingMap(), // 直接進入地圖頁面
    );
  }
}
