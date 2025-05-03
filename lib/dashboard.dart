import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:majorproject/Prediction_screen.dart';
import 'package:majorproject/chat_selection_screen.dart';
import 'package:majorproject/graphs_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'package:majorproject/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:majorproject/ChatScreen.dart';
import 'package:majorproject/chat_service.dart'; // Add this import

class dashboard extends StatefulWidget { // Changed to PascalCase for class name
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<dashboard> {
  int _selectedIndex = 0;
  late String loggedInEmail;

  // Variables to store sensor data
  double temperature = 0.0;
  int heartRate = 0;
  double humidity = 0.0;
  bool isLoading = true;
  Timer? _timer;

  // ThingSpeak API details
  final String channelId = '2440318';
  final String readApiKey = 'DLMK0Q7AAIV2EAOB';

  @override
  void initState() {
    super.initState();
    loggedInEmail = FirebaseAuth.instance.currentUser!.email!;
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 15), (Timer t) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.thingspeak.com/channels/$channelId/feeds/last.json?api_key=$readApiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = double.tryParse(data['field2'] ?? '0') ?? 0.0;
          heartRate = int.tryParse(data['field1'] ?? '0') ?? 0;
          humidity = double.tryParse(data['field3'] ?? '0') ?? 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<Widget> _pages() => [
    _buildLiveMonitoringPage(),
    GraphScreen(),
    PredictionScreen(),
    ChatSelectionScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildLiveMonitoringPage() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSensorCard(
            title: 'Temperature',
            value: '${temperature.toStringAsFixed(1)}°C',
            icon: Icons.thermostat,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          _buildSensorCard(
            title: 'Heart Rate',
            value: '$heartRate BPM',
            icon: Icons.favorite,
            color: Colors.pink,
          ),
          SizedBox(height: 20),
          _buildSensorCard(
            title: 'Humidity',
            value: '${humidity.toStringAsFixed(1)}%',
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 30),
              ],
            ),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Last updated: ${DateTime.now().toString().substring(0, 19)}',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Live Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Graphs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Prediction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}