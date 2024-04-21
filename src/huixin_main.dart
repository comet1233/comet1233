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

class _ThirdPageState extends State<ThirdPage> {
  Map<String, bool>? parkingStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingStatus();
  }

  Future<void> fetchParkingStatus() async {
    Map<String, bool> status = {};
    print('Fetching parking status...');
    await Future.forEach(List.generate(widget.numOfCars, (index) => index + 1), (int i) async {
      print('Fetching status for car $i');
      bool spotStatus = await getCarStatus(i);
      status['car$i'] = spotStatus;
    });
    setState(() {
      parkingStatus = status;
      _isLoading = false; // Mark loading as completed
    });
  }

  Future<bool> getCarStatus(int id) async {
    try {
      final response = await http.get(Uri.parse('http://140.113.126.199:8080/getcar/$id'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Status'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: widget.numOfCars,
                itemBuilder: (context, index) {
                  final spotNumber = index + 1;
                  final isOccupied = parkingStatus!['car$spotNumber'] ?? true;
                  return ParkingSpot(isOccupied: isOccupied);
                },
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
