import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

LatLng initialPosition = LatLng(24.166666, 120.683333); // Taichung, Jinping St

List<Map<String, dynamic>> carParkingLots = [
  {
    'name': 'Parking 1',
    'location': LatLng(24.157075, 120.666144),
    'remaining': 10,
    'rate': 20,
    'address': 'No. 129, Sec. 3, Sanmin Rd, North District, Taichung City'
  },
  {
    'name': 'Parking 2',
    'location': LatLng(24.158754, 120.666999),
    'remaining': 5,
    'rate': 15,
    'address': 'No. 65, Sec. 1, Shuangshi Rd, North District, Taichung City'
  },
  {
    'name': 'Parking 3',
    'location': LatLng(24.156485, 120.675846),
    'remaining': 8,
    'rate': 25,
    'address': 'No. 2, Yucai St, North District, Taichung City'
  },
];

List<Map<String, dynamic>> bikesParkingLots = [
  {
    'name': 'Bike 1',
    'location': LatLng(24.158100, 120.666999),
    'remaining': 10,
    'rate': 20,
    'address': 'Nearby'
  },
  {
    'name': 'Bike 2',
    'location': LatLng(24.157150, 120.680000),
    'remaining': 5,
    'rate': 15,
    'address': 'Nearby'
  },
  {
    'name': 'Bike 3',
    'location': LatLng(24.156000, 120.675000),
    'remaining': 8,
    'rate': 25,
    'address': 'Nearby'
  },
];

class ParkingMap extends StatefulWidget {
  @override
  _ParkingMapState createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  bool showParking = true;
  bool showBikes = false;
  bool showScooters = false;

  final List<LatLng> scooterLocations = List.generate(3, (index) {
    return LatLng(
      initialPosition.latitude + (Random().nextDouble() - 0.5) * 0.01,
      initialPosition.longitude + (Random().nextDouble() - 0.5) * 0.01,
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: initialPosition,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _buildMarkers(context),
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 50,
            child: Column(
              children: [
                Switch(
                  // title: Text('Show Parking Lots'),
                  value: showParking,
                  onChanged: (value) {
                    setState(() {
                      showParking = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Switch(
                  // title: Text('Show Bikes'),
                  value: showBikes,
                  onChanged: (value) {
                    setState(() {
                      showBikes = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Switch(
                  // title: Text('Show Scooters'),
                  value: showScooters,
                  onChanged: (value) {
                    setState(() {
                      showScooters = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    List<Marker> markers = [];

    // 使用者位置的 Marker
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: initialPosition,
        builder: (ctx) => Column(
          children: [
            Icon(Icons.person_pin_circle, color: Colors.red, size: 40.0),
            Text('You', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );

    // 停車場位置的 Marker
    if (showParking) {
      markers.addAll(
        carParkingLots.map((lot) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: lot['location'],
            builder: (ctx) => GestureDetector(
              onTap: () {
                _showParkingDetails(context, lot);
              },
              child: Column(
                children: [
                  Text('${lot['remaining']} / ${lot['rate']}'),
                  Icon(Icons.local_parking, color: Colors.blue, size: 40.0),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // 共享單車位置的 Marker
    if (showBikes) {
      markers.addAll(
        bikesParkingLots.map((lot) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: lot['location'],
            builder: (ctx) => GestureDetector(
              onTap: () {
                _showParkingDetails(context, lot);
              },
              child: Column(
                children: [
                  Text('${lot['remaining']} / ${lot['rate']}'),
                  Icon(Icons.pedal_bike, color: Colors.green, size: 40.0),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // 共享機車位置的 Marker
    if (showScooters) {
      markers.addAll(
        scooterLocations.map((location) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: location,
            builder: (ctx) => Column(
              children: [
                Icon(Icons.electric_scooter, color: Colors.orange, size: 40.0),
                Text('Scooters', style: TextStyle(color: Colors.black)),
              ],
            ),
          );
        }).toList(),
      );
    }

    return markers;
  }

  void _showParkingDetails(BuildContext context, Map<String, dynamic> lot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lot['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remaining Spaces: ${lot['remaining']}'),
              Text('Rate: \$${lot['rate']} per hour'),
              Text('Address: ${lot['address']}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 先關閉對話框
                  final url =
                      'https://www.google.com/maps/dir/?api=1&origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${lot['location'].latitude},${lot['location'].longitude}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text('Navigate'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
