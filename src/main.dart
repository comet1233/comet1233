import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// Sample JSON data, replace it with actual data received from Raspberry Pi
String? jsonDataString = '{"car": {"1": true, "2": false, "3": true, "4": true, "5":false, "6":true, "7":false, "8":true}}';
Map<String, dynamic>? jsonData = jsonDataString != null ? jsonDecode(jsonDataString!) : null;



Future<bool> getCarStatus(int id) async {
  final response = await http.get(Uri.parse('http://172.18.18.26:8080/getcar/$id'));
  if (response.statusCode == 200) {
    // 解析回傳的 JSON 數據
    final Map<String, dynamic> data = jsonDecode(response.body);
    // 返回 true 或 false，表示車位是否被佔用
    return data['status'];
  } else {
    // 如果請求失敗，則返回 null 或者處理其他錯誤情況
    return false;
  }
}


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

  late SharedPreferences _prefs; // 開始

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  } // 結束

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

            const SizedBox(height: 10),
            //password field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String text_username = _usernameController.text;
                String text_password = _passwordController.text;
                _usernameController.clear();
                _passwordController.clear();
                _validateUser(text_username, text_password); // 驗證用戶
              },
              child: const Text('Login'),
            ),

            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: Text('Sign Up',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateUser(String username, String password) {
    //final savedUsername = _prefs.getString('username');
    //final savedPassword = _prefs.getString('password');
    //if (savedUsername == username && savedPassword == password) {
    if (_prefs.containsKey(username) && _prefs.getString(username) == password) {
      // 登入成功
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPage()),
      );
    } else {
      // 登入失敗
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid username or password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _register_usernameController = TextEditingController();
  final TextEditingController _register_passwordController = TextEditingController();
  final TextEditingController _register_confrim_passwordController = TextEditingController();
  bool _isPasswordMatch = true;
  bool _isUsernameEmptySpace = false;
  bool _isPasswordEmptySpace = false;
  late SharedPreferences _prefs; // 開始

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  } // 結束

  @override
  void dispose() {
    _register_usernameController.dispose();
    _register_passwordController.dispose();
    _register_confrim_passwordController.dispose();
    super.dispose();
  }
  void _checkPasswordMatch() {
    setState(() {
      if(_register_passwordController.text == _register_confrim_passwordController.text){
        _isPasswordMatch = true;

      }
      else{
        _isPasswordMatch = false;
        _register_confrim_passwordController.clear();
      }
    }
    );
  }
  void _checkEmptySpace(){
    setState(() {
      if(_register_usernameController.text == '' && _register_passwordController.text == ''){
        _isUsernameEmptySpace = true;
        _isPasswordEmptySpace = true;
      }
      else if(_register_passwordController.text == '' && _register_usernameController.text != ''){
        _isPasswordEmptySpace = true;
        _isUsernameEmptySpace = false;
      }
      else if(_register_usernameController.text == '' && _register_passwordController.text != ''){
        _isUsernameEmptySpace = true;
        _isPasswordEmptySpace = false;
      }
      else{
        _isUsernameEmptySpace = false;
        _isPasswordEmptySpace = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // Username field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _register_usernameController,
                decoration: InputDecoration(

                  hintText: 'Username',
                  errorText: _isUsernameEmptySpace ? 'Please fill in all fields' : null,
                  errorStyle: const TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),

              ),
            ),
            const SizedBox(height: 10),

            //password field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _register_passwordController,
                decoration: InputDecoration(

                  hintText: 'Password',
                  errorText: _isPasswordEmptySpace ? 'Please fill in all fields' : null,
                  errorStyle: const TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 10),

            //confirm password field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _register_confrim_passwordController,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  errorText: _isPasswordMatch ? null : 'Password does not match