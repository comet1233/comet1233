import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String http_address = 'http://140.113.126.199:8080';
int refresh_interval = 5;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Parking Explore'),
          //change title style
          titleTextStyle: const TextStyle(
            color: Color.fromARGB(255, 73, 73, 73),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Username field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _usernameController.clear();
                _passwordController.clear();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search your parking lot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownMenu<String>(
                requestFocusOnTap: true,
                leadingIcon: const Icon(Icons.search),
                label: const Text('Parking Lot'),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                width: 500,
                menuHeight: 50,
                hintText: ('Select a parking lot'),
                dropdownMenuEntries: [DropdownMenuEntry(value: 'value', label: 'lot1')],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThirdPage(numOfCars: 10)),
                );
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  final int numOfCars;

  const ThirdPage({Key? key, required this.numOfCars}) : super(key: key);
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> with AutomaticKeepAliveClientMixin {
  Map<String, bool>? parkingStatus;
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Fetch parking status initially
    fetchParkingStatus();
    // Start a periodic timer to refresh data every 30 seconds
    _timer = Timer.periodic(Duration(seconds: refresh_interval), (timer) {
      fetchParkingStatus();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchParkingStatus() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching data
    });
    Map<String, bool> status = {};
    print('Fetching parking status...');
    try {
      await Future.forEach(
          List.generate(10, (index) => index + 1), (int i) async {
        print('Fetching status for car $i');
        bool spotStatus = await getCarStatus(i);
        status['car$i'] = spotStatus;
      });
      setState(() {
        parkingStatus = status;
        _isLoading = false; // Mark loading as completed
      });
    } catch (e) {
      print('Error fetching parking status: $e');
      // Handle error, for example, show a snackbar or toast
    }
  }

  Future<bool> getCarStatus(int id) async {
    try {
      final response = await http.get(Uri.parse('$http_address/getcar/$id'));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is bool) {
          return data;
        } else {
          print('Error: Response data is not a boolean value');
          return false;
        }
      } else {
        print('Error: HTTP request failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  bool? _previousLoadingState;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Status'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Adjust animation duration as needed
        child: _isLoading
            ? _buildLoadingIndicator(_previousLoadingState)
            : _buildParkingGrid(),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool? previousLoadingState) {
    // If previousLoadingState is null or true, show a CircularProgressIndicator,
    // otherwise show the content from the last state where isLoading was false.
    return Center(
      key: UniqueKey(), // Ensure AnimatedSwitcher recognizes this as a new child
      child: previousLoadingState == null
          ? CircularProgressIndicator()
          : _buildParkingGrid(),
    );
  }

  Widget _buildParkingGrid() {
    return Center(
      key: UniqueKey(), // Ensure AnimatedSwitcher recognizes this as a new child
      child: CustomMultiChildLayout(
        delegate: _ParkingLayoutDelegate(), // Use custom layout delegate
        children: List.generate(widget.numOfCars, (index) {
          final spotNumber = index + 1;
          final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
          return LayoutId(
            id: 'car$spotNumber',
            child: ParkingSpot(isOccupied: isOccupied),
          );
        }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ParkingLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final childWidth = size.width / 7 - 3.0; // 设置每个车位的宽度
    final childHeight = 100.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距
    final totalChildren = 10; // 设置总车位数


    final offsetX = <double>[childWidth*2 + spacing*2, childWidth * 3 + spacing * 3, childWidth * 4 + spacing * 4,
                            1.0*childWidth, childWidth * 5.5 + spacing * 6, 
                            1.0*childWidth, childWidth * 5.5 + spacing * 6,
                            childWidth*2 + spacing*2, childWidth * 3 + spacing * 3, childWidth * 4 + spacing * 4];
    final offsetY = <double>[ 0, 0, 0, 1.75 * childHeight + 2*spacing, 1.75*childHeight + 2*spacing,
                           2.75*childHeight + 3*spacing, 2.75*childHeight + 3*spacing,
                            childHeight * 5 + spacing * 5, childHeight * 5 + spacing * 5, childHeight * 5 + spacing * 5];
    for (int i = 0; i < totalChildren; i++) {
      final String childId = 'car${i + 1}';

      if (hasChild(childId)) {
        if(i<=2 || i>=7)
          final childSize = layoutChild(childId, BoxConstraints.loose(Size(childWidth, childHeight/2)));
        else 
          final childSize = layoutChild(childId, BoxConstraints.loose(Size(childWidth/2, childHeight)));
        
        positionChild(childId, Offset(offsetX[i], offsetY[i]));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
  int get count => 10;
}


class ParkingSpot extends StatefulWidget {
  final bool isOccupied;

  const ParkingSpot({Key? key, required this.isOccupied}) : super(key: key);

  @override
  State<ParkingSpot> createState() => _ParkingSpotState();
}

class _ParkingSpotState extends State<ParkingSpot> {
  late Color spotColor;

  @override
  void initState() {
    super.initState();
    spotColor = widget.isOccupied ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: spotColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
    );
  }
}

//--------------------------------------------------------------------------------------------

// // Copyright 2013 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// import 'package:parking_0331/location_service.dart';

// void main() => runApp(Myapp());

// class Myapp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps',
//       home: MapSample(),
//     );
//   }
// }

// class MapSample extends StatefulWidget {
//   const MapSample({super.key});

//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   final Completer<GoogleMapController> _controller =Completer<GoogleMapController>();
//   final TextEditingController _searchController = TextEditingController();

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//   static final Marker _kGooglePlexMarker = Marker(
//       markerId: MarkerId('_kGooglePlex'),
//       position: LatLng(37.42796133580664, -122.085749655962),
//       infoWindow: InfoWindow(title: 'Googleplex'),
//       icon: BitmapDescriptor.defaultMarker);
//   static const CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);

//   static final Marker _kLakePlexMarker = Marker(
//       markerId: MarkerId('_kLakePlex'),
//       position: LatLng(37.43296265331129, -122.08832357078792),
//       infoWindow: InfoWindow(title: 'Lakeplex'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet));
//   static final Polyline _kPolyline = Polyline(
//     polylineId: PolylineId('poly'),
//     color: Colors.red,
//     points: <LatLng>[
//       LatLng(37.42796133580664, -122.085749655962),
//       LatLng(37.43296265331129, -122.08832357078792),
//     ],
//   );
//   static final Polygon _kPolygon = Polygon(
//     polygonId: PolygonId('poly'),
//     fillColor: Colors.green,
//     points: <LatLng>[
//       LatLng(37.42796133580664, -122.085749655962),
//       LatLng(37.43296265331129, -122.08832357078792),
//       LatLng(37.43296265331129, -122.08832357078792),
//       LatLng(37.42796133580664, -122.085749655962),
//     ],
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Google Maps'),
//         backgroundColor: Colors.green[700],
//       ),
//       body: Column(
//         children: [
//           Row(children: [
//             Expanded(child: TextFormField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 print(value);
//               },
//             )),
//             IconButton(
//               icon: Icon(Icons.search),
//               onPressed: () {
//                 LocationService().getPlace(_searchController.text);
//               },
//             ),
//           ],),

//           Expanded(
//             child: GoogleMap(
//               mapType: MapType.hybrid,
//               markers: {
//                 _kGooglePlexMarker, /*_kLakePlexMarker*/
//               },
//               // polylines: { _kPolyline },
//               // polygons: { _kPolygon },
//               initialCameraPosition: _kGooglePlex,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _goToTheLake,
//       //   label: const Text('To the lake!'),
//       //   icon: const Icon(Icons.directions_boat),
//       // ),
//     );
//   }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
// }
