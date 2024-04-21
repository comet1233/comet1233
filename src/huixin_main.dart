// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/material.dart';
// // import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// String? jsonDataString = '{"car": {"1": true, "2": false, "3": true, "4": true, "5":false, "6":true, "7":false, "8":true}}';
// Map<String, dynamic>? jsonData = jsonDataString != null ? jsonDecode(jsonDataString!) : null;


// Future<bool> getCarStatus(int id) async {
//   final response = await http.get(Uri.parse('http://140.113.126.199:8080//getcar/$id'));
//   if (response.statusCode == 200) {
//     // 解析回傳的 JSON 數據
//     final Map<String, dynamic> data = jsonDecode(response.body);
//     // 返回 true 或 false，表示車位是否被佔用
//     return data['status'];
//   } else {
//     // 如果請求失敗，則返回 null 或者處理其他錯誤情況
//     return false;
//   }
// }



// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _isDarkMode = false;

//   void _toggleTheme() {
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Parking Explore'),
//           //change title style
//           titleTextStyle: const TextStyle(
//             color: Color.fromARGB(255, 73, 73, 73),
//             fontSize: 25,
//             fontWeight: FontWeight.bold,
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
//               onPressed: _toggleTheme,
              
//             ),
//           ],
//         ),
//         body: LoginPage(),
//       ),
//     );
//   }
// }

// class LoginPage extends StatefulWidget {
//   LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();


//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[

//             // Username field
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   hintText: 'Username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _usernameController.clear();
//                 _passwordController.clear();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SearchPage()),
//                 );
//               },
//               child: const Text('Login'),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   String? _selectedOption;
//   final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search your parking lot'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: DropdownMenu<String>(
//                 requestFocusOnTap: true,
//                 leadingIcon: const Icon(Icons.search),
//                 label: const Text('Parking Lot'),
//                 inputDecorationTheme: const InputDecorationTheme(
//                         filled: true,
//                         contentPadding: EdgeInsets.symmetric(vertical: 5.0),
//                       ),
//                 width: 500,
//                 menuHeight: 50,
//                 hintText: ('Select a parking lot'),
//               dropdownMenuEntries: [DropdownMenuEntry(value: 'value', label: 'lot1')],
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ThirdPage()),
//                 );
//               },
//               child: const Text('Search'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class ThirdPage extends StatefulWidget {
//   const ThirdPage({Key? key}) : super(key: key);

//   @override
//   _ThirdPageState createState() => _ThirdPageState();
// }

// class _ThirdPageState extends State<ThirdPage> {
//   Map<String, bool>? parkingStatus;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchParkingStatus();
//   }

//  Future<void> fetchParkingStatus() async {
//   // Fetch parking status for each spot
//   Map<String, bool> status = {};
//   await Future.forEach(List.generate(8, (index) => index + 1), (int i) async {
//     bool spotStatus = await getCarStatus(i);
//     status['car$i'] = spotStatus;
//   });
//   setState(() {
//     parkingStatus = status;
//     _isLoading = false; // Mark loading as completed
//   });
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Parking Status'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator()) // Show loading indicator
//           : Center(
//               child: GridView.count(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20,
//                 padding: const EdgeInsets.all(20),
//                 children: List.generate(8, (index) {
//                   final spotNumber = index + 1;
//                   final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
//                   return ParkingSpot(isOccupied: isOccupied);
//                 }),
//               ),
//             ),
//     );
//   }
// }


// class ParkingSpot extends StatefulWidget {
//   final bool isOccupied;

//   const ParkingSpot({super.key, required this.isOccupied});

//   @override
//   State<ParkingSpot> createState() => _ParkingSpotState();
// }

// class _ParkingSpotState extends State<ParkingSpot> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         color: widget.isOccupied ? Colors.red : Colors.green,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: Colors.black,
//           width: 2,
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String? _selectedOption;
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

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
                  MaterialPageRoute(builder: (context) => const ThirdPage()),
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
  const ThirdPage({Key? key}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  Map<String, bool>? parkingStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingStatus();
  }

  Future<void> fetchParkingStatus() async {
    // Fetch parking status for each spot
    Map<String, bool> status = {};
    // Add debug log to see when this function is called
    print('Fetching parking status...');
    await Future.forEach(List.generate(8, (index) => index + 1), (int i) async {
      print('Fetching status for car $i');
      bool spotStatus = await getCarStatus(i);
      status['car$i'] = spotStatus;
    });
    setState(() {
      parkingStatus = status;
      _isLoading = false; // Mark loading as completed
    });
    //"""print the status of each parking spot""";
    // print('Parking status: $status');
  }
  

Future<bool> getCarStatus(int id) async {
  try {
    final response = await http.get(Uri.parse('http://140.113.126.199:8080/getcar/$id'));
    if (response.statusCode == 200) {
      // 解析回傳的 JSON 數據
      final dynamic data = jsonDecode(response.body);
      // 检查数据是否为布尔类型
      if (data is bool) {
        return data; // 返回布尔值
      } else {
        print('Error: Response data is not a boolean value');
        return false;
      }
    } else {
      // 如果請求失敗，則返回 null 或者處理其他錯誤情況
      print('Error: HTTP request failed with status code ${response.statusCode}');
      return false;
    }
  } catch (e) {
    // 捕獲異常
    print('Error: $e');
    return false;
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Status'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Center(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: const EdgeInsets.all(20),
                children: List.generate(8, (index) {
                  final spotNumber = index + 1;
                  final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
                  return ParkingSpot(isOccupied: isOccupied);
                }),
              ),
            ),
    );
  }
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
    // 在 initState 中設置初始顏色
    spotColor = widget.isOccupied ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: spotColor, // 使用 spotColor
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
    );
  }
}
