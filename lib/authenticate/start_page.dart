import 'package:flutter/material.dart';
import 'package:visiosense/authenticate/profile_page.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:visiosense/server/mqtt_service.dart';
void main() {
  runApp(VisiosenseApp());
}

class VisiosenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late MqttService _mqttService;
  double _currentSliderValue = 50;
  bool isTextReadingEnabled = false;
  bool isFaceRecognitionEnabled = false;
  String buttonTitle = "START";
  bool isDetectionActive = false;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService('broker.hivemq.com', 'flutter_client');
    _mqttService.connect();
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  void _connectMQTT() {
    // Your MQTT connection logic here
    _mqttService.connect();
  }

  void _disconnectMQTT() {
    // Your MQTT disconnection logic here
    _mqttService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Container(
                  width: 500,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.jpg',
                            height: 80,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Visio Sense',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.account_circle, size: 40),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.volume_up, size: 40, color: Colors.black),
                      SizedBox(height: 20),
                      SleekCircularSlider(
                        min: 0,
                        max: 100,
                        initialValue: _currentSliderValue,
                        onChange: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        },
                        innerWidget: (double value) {
                          return Center(
                            child: Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'MIN',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'MAX',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildToggleOption(
                          title: "Text Reading",
                          value: isTextReadingEnabled,
                          onChanged: (value) {
                            setState(() {
                              isTextReadingEnabled = value;
                            });
                          }),
                      SizedBox(height: 10),
                      _buildToggleOption(
                          title: "Face Recognition",
                          value: isFaceRecognitionEnabled,
                          onChanged: (value) {
                            setState(() {
                              isFaceRecognitionEnabled = value;
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(height: 100),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Toggle the detection state
                        isDetectionActive = !isDetectionActive;
                        buttonTitle = isDetectionActive ? "STOP" : "START";

                        // Connect or disconnect from MQTT based on the detection state
                        if (isDetectionActive) {
                          _connectMQTT();
                        } else {
                          _disconnectMQTT();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(400, 60),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(buttonTitle, style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
      {required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
