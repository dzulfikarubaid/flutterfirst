import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import pustaka untuk JSON parsing
import 'package:logger/logger.dart'; // Import pustaka logger
import 'dart:async'; // Import pustaka timer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final logger = Logger();
  double firstDataValue = 0.0; // Variabel di sini

  late Timer _fetchDataTimer;

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://aeli.vercel.app/api/nizaar'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null && responseData['data'].isNotEmpty) {
        final firstDataKey = responseData['data'].keys.first;
        firstDataValue = responseData['data'][firstDataKey]; // Menyimpan nilai dalam variabel
        logger.d('First data key: $firstDataKey, First data value: $firstDataValue');
        setState(() {}); // Memanggil setState untuk memperbarui tampilan
      } else {
        logger.w('No data available in the response');
      }
    } else {
      logger.e('Request failed with status: ${response.statusCode}');
    }
  }

  void _fetchDataPeriodically() {
    _fetchData(); 
    _fetchDataTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _fetchData(); 
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDataPeriodically();
  }

  @override
  void dispose() {
    _fetchDataTimer.cancel(); // Batalkan timer saat widget dihapus
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              '$firstDataValue', // Menampilkan nilai di sini
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
