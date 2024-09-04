import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

String http_address = 'http://140.113.177.190:8080';
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
                //width: ,//
                //set the width of the dropdown menu the adjustable  width of the screen
                width: MediaQuery.of(context).size.width * 0.8,
                menuHeight: 50,
                hintText: ('Select a parking lot'),
                dropdownMenuEntries: [DropdownMenuEntry(value: 'value', label: 'Songshan Cultural and Creative Park')],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage(numOfCars: 10, verticalOffset: 10.0)),
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
  final double verticalOffset; // 新增的垂直位移

  const ThirdPage({Key? key, required this.numOfCars, required this.verticalOffset}) : super(key: key);
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> with AutomaticKeepAliveClientMixin {
  Map<String, bool>? parkingStatus;
  bool _isLoading = true;
  late Timer _timer;
  bool _showNavigation = false; // 新增的變量，用於控制是否顯示導航

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
        bool spotStatus = await getCarStatus(11 - i);
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
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            
            onPressed: () {
              setState(() {
                _showNavigation = !_showNavigation; // Toggle the navigation visibility
              });
            },
          ),
          Text("Navigation"),
        ],
      ),
      body: Container(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500), // Adjust animation duration as needed
          child: _isLoading
              ? _buildLoadingIndicator(_previousLoadingState)
              : _showNavigation // Check if navigation should be shown
                  ? _buildParkingGridWithNavigation()
                  : _buildParkingGrid(),
        ),
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final childWidth = width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距
    
    final startPoint = Offset(spacing*4, childHeight * 5.5+ spacing * 4); 
    
    return Center(
      key: UniqueKey(), // Ensure AnimatedSwitcher recognizes this as a new child
      child: Stack(
        children: [
          CustomPaint(
            painter: CenterParkingSpotPainter(context:context, startPoint: startPoint), // Pass the BuildContext to the painter
            
            size: Size(double.infinity, double.infinity),
          ),
          CustomMultiChildLayout(
            delegate: _ParkingLayoutDelegate(),
            children: List.generate(widget.numOfCars, (index) {
              final spotNumber = index + 1;
              final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
              return LayoutId(
                id: 'car$spotNumber',
                child: Padding(
                  // 添加 Padding 並設置垂直位移
                  padding: EdgeInsets.only(top: widget.verticalOffset),
                  child: ParkingSpot(isOccupied: isOccupied),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  Offset? _nearestEmptySpotPosition;
  Widget _buildParkingGridWithNavigation() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final childWidth = width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距
    
    final startPoint = Offset(spacing*4, childHeight * 5.5+ spacing * 4); 
    
    // 如果没有停车状态数据，则不绘制导航路径
    if (parkingStatus == null) {
      return _buildParkingGrid(); // 返回普通停车场视图
    }

    // 找到最近的空车位的编号
    final nearestEmptySpotNumber = _findNearestEmptySpot();
    // 如果找到了最近的空车位编号，则计算其位置
    if (nearestEmptySpotNumber != null) {
      _nearestEmptySpotPosition = _calculateEmptySpotPosition(nearestEmptySpotNumber);
    }

    return Center(
      key: UniqueKey(),
      child: Stack(
        children: [
          CustomPaint(
            painter: CenterParkingSpotPainter(context:context,startPoint:startPoint),
            size: Size(double.infinity, double.infinity),
          ),
          if (_nearestEmptySpotPosition != null) // 如果存在最近的空车位位置，则绘制导航路径
            CustomPaint(
              
                painter: NavigationPainter(
                startPoint: startPoint, // 起点为左上角
                spotNumber: nearestEmptySpotNumber  !, // 终点为最近空车位位置
              ),
              size: Size(double.infinity, double.infinity),
            ),
          CustomMultiChildLayout(
            delegate: _ParkingLayoutDelegate(),
            children: List.generate(widget.numOfCars, (index) {
              final spotNumber = index + 1;
              final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
              return LayoutId(
                id: 'car$spotNumber',
                child: Padding(
                  padding: EdgeInsets.only(top: widget.verticalOffset),
                  child: ParkingSpot(isOccupied: isOccupied),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
 int? _findNearestEmptySpot() {
    double minDistance = double.infinity;
    int? nearestEmptySpotNumber;
    parkingStatus!.forEach((key, value) {
      final spotNumber = int.parse(key.substring(3)); // 从 'car' 字符串后获取车位编号
      // $spotNumber, value: $value");
      if (value) {
        // 如果是空车位
        final distance = _calculateDistanceToEmptySpot(spotNumber);
        if (distance < minDistance) {
          minDistance = distance;
          nearestEmptySpotNumber = spotNumber;
        }
      }
    });
    // print('Nearest empty spot: $nearestEmptySpotNumber');
    return nearestEmptySpotNumber;
  }

  // 计算到最近空车位的距离
  double _calculateDistanceToEmptySpot(int spotNumber) {
    // 这里假设停车位在网格中均匀分布，计算直线距离作为近似距离
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final childWidth = width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距
    
    final startPoint = Offset(spacing*4, childHeight * 5.5+ spacing * 4); 
    final emptySpotPosition = _calculateEmptySpotPosition(spotNumber);
    return (startPoint - emptySpotPosition).distance; // 返回距离);
  }

  // 计算空车位的位置
  Offset _calculateEmptySpotPosition(int spotNumber) {
    // Size size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final childWidth = width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距


    final offsetX = <double>[childWidth*4.5 + spacing*4, childWidth * 5.5 + spacing * 5, childWidth * 6.5 + spacing * 6,
                            1*childWidth+spacing * 2, childWidth * 11+spacing * 2, 
                            1*childWidth+spacing * 2, childWidth * 11 +spacing * 2,
                            childWidth*4.5 + spacing*4, childWidth * 5.5 + spacing * 5, childWidth * 6.5 + spacing * 6];
    final offsetY = <double>[ 3 , 3, 3, 
                            2 * childHeight + 1*spacing, 2*childHeight + 1*spacing,
                           3*childHeight + 2*spacing, 3*childHeight + 2*spacing,
                            childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4];
   
    return Offset(offsetX[spotNumber-1], offsetY[spotNumber-1]);
}


  @override
  bool get wantKeepAlive => true;
}

class NavigationPainter extends CustomPainter {
  final Offset startPoint; // 起点
  //final Offset endPoint; // 终点
  final int spotNumber;

  NavigationPainter({
    required this.startPoint,
    required this.spotNumber,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5.0;
    //------------------------------------------------------------

    final childWidth = size.width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = size.height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距


    final offsetX = <double>[childWidth*4.5 + spacing*4, childWidth * 5.5 + spacing * 5, childWidth * 6.5 + spacing * 6,
                            1*childWidth+spacing * 2, childWidth * 11+spacing * 2, 
                            1*childWidth+spacing * 2, childWidth * 11 +spacing * 2,
                            childWidth*4.5 + spacing*4, childWidth * 5.5 + spacing * 5, childWidth * 6.5 + spacing * 6];
    final offsetY = <double>[ 3 , 3, 3, 
                            2 * childHeight + 1*spacing, 2*childHeight + 1*spacing,
                           3*childHeight + 2*spacing, 3*childHeight + 2*spacing,
                            childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4];
   



    final path = Path();
    switch (spotNumber) {
      case 1:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, offsetY[0]);
        path.lineTo(offsetX[0], offsetY[0]);
        final c = Offset(offsetX[0], offsetY[0]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 2:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, offsetY[1]);
        path.lineTo(offsetX[1], offsetY[1]);
        final c = Offset(offsetX[1], offsetY[1]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 3:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, offsetY[2]);
        path.lineTo(offsetX[2], offsetY[2]);
        final c = Offset(offsetX[2], offsetY[2]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 4:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, offsetY[3]);
        final c = Offset(startPoint.dx, offsetY[3]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 5:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(offsetX[4], startPoint.dy);
        path.lineTo(offsetX[4], offsetY[4]);
        final c = Offset(offsetX[4], offsetY[4]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 6:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, offsetY[5]);
        final c = Offset(startPoint.dx, offsetY[5]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 7:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(offsetX[6], startPoint.dy);
        path.lineTo(offsetX[6], offsetY[6]);
        final c = Offset(offsetX[6], offsetY[6]);
        canvas.drawCircle(c, 3, paint);
        break;
      case 8:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(offsetX[7], startPoint.dy);
        final c = Offset(offsetX[7], startPoint.dy);
        canvas.drawCircle(c, 3, paint);
        break;
      case 9:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(offsetX[8], startPoint.dy);
        final c = Offset(offsetX[8], startPoint.dy);
        canvas.drawCircle(c, 3, paint);
        break;
      case 10:
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(offsetX[9], startPoint.dy);
        final c = Offset(offsetX[9], startPoint.dy);
        canvas.drawCircle(c, 3, paint);
        break;
    }
    print('Nearest empty spot: $spotNumber');
    
    canvas.drawPath(path, paint);
    
    final center = Offset(startPoint.dx, startPoint.dy);
    final rect = Rect.fromCenter(center: center, width: 5, height: 5);
    canvas.drawRect(rect, paint);

    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class CenterParkingSpotPainter extends CustomPainter {
  final BuildContext context; // 新增的屬性
  final Offset startPoint; 
  CenterParkingSpotPainter({required this.context, required this.startPoint}); // 構造函數

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;

    // Get the screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 計算車位高度
    final childHeight = screenHeight / 8 - 3.0; // 與 _ParkingLayoutDelegate 中的計算方式一致

    // 計算長方形高度（等於車位012和車位789的間距）
    final rectHeight = childHeight * 3 + 3.0; // 與車位高度相同

    // 計算長方形中心點（在車位012和車位789的正中間）
    final centerOffsetY = childHeight * 2.5 + 1 * 1.5; // 與 _ParkingLayoutDelegate 中的 offsetY 相同
    final center = Offset(size.width / 2, centerOffsetY);

    // 計算長方形寬度
    final rectWidth = screenWidth / 1.5;

    final rect = Rect.fromCenter(center: center, width: rectWidth, height: rectHeight);
    canvas.drawRect(rect, paint);

    Paint paint1 = Paint();
    paint1.color = Colors.blue;
    paint1.style = PaintingStyle.stroke;
    paint1.strokeWidth = 5.0;
    final center1 = Offset(startPoint.dx, startPoint.dy);
    final rect1 = Rect.fromCenter(center: center1, width: 5, height: 5);
    canvas.drawRect(rect1, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}





class _ParkingLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final childWidth = size.width / 11 - 3.0; // 设置每个车位的宽度
    final childHeight = size.height/8 - 3.0; // 设置每个车位的高度
    final spacing = 3.0; // 设置每个车位之间的间距
    final totalChildren = 10; // 设置总车位数


    final offsetX = <double>[childWidth*4 + spacing*4, childWidth * 5 + spacing * 5, childWidth * 6 + spacing * 6,
                            1*childWidth+spacing * 2, childWidth * 10+spacing * 2, 
                            1*childWidth+spacing * 2, childWidth * 10 +spacing * 2,
                            childWidth*4 + spacing*4, childWidth * 5 + spacing * 5, childWidth * 6 + spacing * 6];
    final offsetY = <double>[ 0 , 0, 0, 
                            1.5 * childHeight + 1*spacing, 1.5*childHeight + 1*spacing,
                           2.5*childHeight + 2*spacing, 2.5*childHeight + 2*spacing,
                            childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4, childHeight * 4.5 + spacing * 4];
    for (int i = 0; i < totalChildren; i++) {
      final String childId = 'car${i + 1}';

      if (hasChild(childId)) {
        if(i<=2 || i>=7)
          final childSize = layoutChild(childId, BoxConstraints.loose(Size(childWidth, childHeight/2)));
        else 
          final childSize = layoutChild(childId, BoxConstraints.loose(Size(childWidth/2, childHeight)));

        //print("offsetX of $i: ${offsetX[i]}, offsetY: ${offsetY[i]}");
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
