import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentPosition = LatLng(0, 0);
  double _currentAccuracy = 0;

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  Future<void> _locateUser() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _currentAccuracy = position.accuracy;
      _mapController.move(_currentPosition, 15.0);
    });
  }

  Future<List<String>> _getSuggestions(String query) async {
    List<Location> locations = await locationFromAddress(query);
    return locations.map((loc) => "${loc.latitude}, ${loc.longitude}").toList();
  }

  void _navigateToLocation(String location) async {
    List<Location> locations = await locationFromAddress(location);
    if (locations.isNotEmpty) {
      final LatLng target = LatLng(locations[0].latitude, locations[0].longitude);
      _mapController.move(target, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Map Example"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(),
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              LocationMarkerLayer(
                position: LocationMarkerPosition(
                  latitude: _currentPosition.latitude,
                  longitude: _currentPosition.longitude,
                  accuracy: _currentAccuracy,
                ),
                style: LocationMarkerStyle(),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: TypeAheadField<String>(
              suggestionsCallback: (pattern) async {
                return await _getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(suggestion),
                );
              },
              onSelected: (suggestion) {
                _navigateToLocation(suggestion);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: _searchController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search for a place',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                );
              },
              animationDuration: Duration(milliseconds: 200),
              debounceDuration: Duration(milliseconds: 300),
              direction: VerticalDirection.down,
              loadingBuilder: (context) => Center(child: CircularProgressIndicator()),
              errorBuilder: (context, error) => ListTile(
                title: Text('Error: $error'),
              ),
              emptyBuilder: (context) => Center(child: Text('No results found')),
              transitionBuilder: (context, controller, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(controller),
                  child: child,
                );
              },
              decorationBuilder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: child,
                );
              },
              listBuilder: (context, items) {
                return ListView(
                  children: items,
                );
              },
              constraints: BoxConstraints(maxHeight: 200),
              offset: Offset(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
