import 'package:flutter/material.dart';
import 'package:parking_app/parking_map.dart';

void main() {
  runApp(ParkingApp());
}

class ParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParkingHomePage(),
    );
  }
}

class ParkingHomePage extends StatefulWidget {
  @override
  _ParkingHomePageState createState() => _ParkingHomePageState();
}

class _ParkingHomePageState extends State<ParkingHomePage> {
  String selectedParking = "Parking 1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Availability'),
        actions: [
          DropdownButton<String>(
            value: selectedParking,
            items: parkingLots.map((lot) {
              return DropdownMenuItem<String>(
                value: lot['name'],
                child: Text(lot['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedParking = value!;
              });
            },
          ),
        ],
      ),
      body: ParkingMap(),
    );
  }
}
