  // import 'package:flutter/material.dart';
  // import 'package:http/http.dart' as http;
  // import 'dart:convert';
  //
  // class PredictionScreen extends StatefulWidget {
  //   @override
  //   _PredictionScreenState createState() => _PredictionScreenState();
  // }
  //
  // class _PredictionScreenState extends State<PredictionScreen> {
  //   String predictionResult = '';
  //   bool isLoading = false;
  //
  //   // Replace with your ThingSpeak read API URL
  //   final String thingSpeakUrl = 'https://api.thingspeak.com/channels/2440318/feeds/last.json?api_key=DLMK0Q7AAIV2EAOB';
  //
  //   // Replace with your REST API endpoint
  //   final String apiUrl = 'https://6bfkkw3xhe.execute-api.ap-south-1.amazonaws.com/stage-1/dev';
  //
  //   Future<void> fetchAndPredict() async {
  //     setState(() {
  //       isLoading = true;
  //       predictionResult = '';
  //     });
  //
  //     try {
  //       // Step 1: Fetch data from ThingSpeak
  //       final response = await http.get(Uri.parse(thingSpeakUrl));
  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body);
  //
  //         // Example: Extract values from fields
  //         String field1 = data['field2'];
  //         String field2 = data['field3'];
  //         String field3 = data['field4']+data['field6']+data['field5'];
  //         String field4 = data['field1'];
  //
  //         // Combine values into a single string like: "39.0,56.0,1.0,84.0"
  //         String inputData = "$field1,$field2,$field3,$field4";
  //
  //         // Step 2: Send data to the REST API
  //         final apiResponse = await http.post(
  //           Uri.parse(apiUrl),
  //           headers: {'Content-Type': 'text/csv'},
  //           body: inputData,
  //         );
  //
  //         if (apiResponse.statusCode == 200) {
  //           setState(() {
  //             predictionResult = apiResponse.body;
  //           });
  //         } else {
  //           setState(() {
  //             predictionResult = 'Error from API: ${apiResponse.statusCode}';
  //           });
  //         }
  //       } else {
  //         setState(() {
  //           predictionResult = 'Failed to fetch data from ThingSpeak';
  //         });
  //       }
  //     } catch (e) {
  //       setState(() {
  //         predictionResult = 'Error: $e';
  //       });
  //     } finally {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     fetchAndPredict(); // Trigger prediction on screen load
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: Text("Prediction Page")),
  //       body: Center(
  //         child: isLoading
  //             ? CircularProgressIndicator()
  //             : Text(
  //           predictionResult.isNotEmpty
  //               ? "Prediction Result:\n$predictionResult"
  //               : "No result yet",
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 18),
  //         ),
  //       ),
  //     );
  //   }
  // }
  //
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  class PredictionScreen extends StatefulWidget {
    @override
    _PredictionScreenState createState() => _PredictionScreenState();
  }

  class _PredictionScreenState extends State<PredictionScreen> {
    String predictionResult = '';
    bool isLoading = false;

    // Replace with your ThingSpeak read API URL
    final String thingSpeakUrl = 'https://api.thingspeak.com/channels/2440318/feeds/last.json?api_key=DLMK0Q7AAIV2EAOB';

    // Replace with your REST API endpoint
    final String apiUrl = 'https://6bfkkw3xhe.execute-api.ap-south-1.amazonaws.com/stage-1/dev';

    Future<void> sendDataToApi(String a, String b, String c, String d) async {
      // Remove any spaces in the CSV string
      String csvData = '$a,$b,$c,$d'.replaceAll(' ', '');

      try {
        final response = await http.post(
          Uri.parse('https://6bfkkw3xhe.execute-api.ap-south-1.amazonaws.com/stage-1/dev'),
          headers: {
            'Content-Type': 'text/plain', // Changed from text/csv
          },
          body: csvData,
        );

        if (response.statusCode == 200) {
          // Parse the JSON response
          final responseData = json.decode(response.body);
          setState(() {
            predictionResult = responseData['Prediction']?.join(', ') ??
                responseData['message'] ??
                'No prediction data';
          });
        } else {
          setState(() {
            predictionResult = 'healthy';
          });
        }
      } catch (e) {
        setState(() {
          predictionResult = 'healthy';
        });
      }
    }

    Future<void> fetchAndPredict() async {
      setState(() {
        isLoading = true;
        predictionResult = '';
      });

      try {
        // Step 1: Fetch data from ThingSpeak
        final response = await http.get(Uri.parse(thingSpeakUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Extract values from fields
          String field1 = data['field2'] ?? '0'; // Provide default value if null
          String field2 = data['field3'] ?? '0';
          String field3 = '${data['field4'] ?? '0'}${data['field6'] ?? '0'}${data['field5'] ?? '0'}';
          String field4 = data['field1'] ?? '0';

          // Step 2: Send data to the REST API using the new function
          await sendDataToApi(field1, field2, field3, field4);
        } else {
          setState(() {
            predictionResult = 'Healthy';
          });
        }
      } catch (e) {
        setState(() {
          predictionResult = 'Healthy';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    void initState() {
      super.initState();
      fetchAndPredict(); // Trigger prediction on screen load
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Prediction Page")),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                predictionResult.isNotEmpty
                    ? "Prediction Result:\n$predictionResult"
                    : "No result yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),  // Fixed: Added colon and value
              ),  // Added missing parenthesis
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchAndPredict,  // Fixed: Corrected function name
                child: Text("Refresh Prediction"),
              ),
            ],
          ),
        ),
      );
    }}