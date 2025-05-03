import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<FlSpot> temperatureData = [];
  List<FlSpot> humidityData = [];
  List<FlSpot> heartRateData = [];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchThingSpeakData();

    // Refresh every 15 seconds
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      fetchThingSpeakData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<void> fetchThingSpeakData() async {
    final response = await http.get(Uri.parse('https://api.thingspeak.com/channels/2440318/feeds.json?api_key=DLMK0Q7AAIV2EAOB&results=50'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feeds = data['feeds'] as List<dynamic>?;

      if (feeds == null) return;

      List<FlSpot> tempList = [];
      List<FlSpot> humList = [];
      List<FlSpot> heartList = [];

      for (int i = 0; i < feeds.length; i++) {
        final item = feeds[i];
        final x = i.toDouble();
        final temp = double.tryParse(item['field1'] ?? '') ?? 0.0;
        final hum = double.tryParse(item['field2'] ?? '') ?? 0.0;
        final heart = double.tryParse(item['field3'] ?? '') ?? 0.0;

        tempList.add(FlSpot(x, temp));
        humList.add(FlSpot(x, hum));
        heartList.add(FlSpot(x, heart));
      }

      setState(() {
        temperatureData = tempList;
        humidityData = humList;
        heartRateData = heartList;
      });
    } else {
      print('Failed to load data');
    }
  }

  Widget buildGraph(String title, List<FlSpot> data, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 200, child: LineChart(LineChartData(
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  barWidth: 2,
                  color: color,
                  dotData: FlDotData(show: false),
                )
              ],
            ))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graph Page'),
        automaticallyImplyLeading: false, // Removes back arrow
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildGraph('Heart Rate in Bpm', temperatureData, Colors.red),
            buildGraph('Humidity', humidityData, Colors.blue),
            buildGraph('Temperature', heartRateData, Colors.green),
          ],
        ),
      ),
    );
  }
}
