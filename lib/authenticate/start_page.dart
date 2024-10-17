import 'package:flutter/material.dart';
import 'package:visiosense/authenticate/profile_page.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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

// Convert StartPage to StatefulWidget
class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double _currentSliderValue = 50; // Initialize the slider value

  bool isTextReadingEnabled = false;
  bool isFaceRecognitionEnabled = false;
  String buttonTitle = "START";

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Path to background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),

                // Guardian Container
                Container(
                  width: 500,
                  height: 60,
                  // padding: const EdgeInsets.all(16.0),
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
                            'assets/logo.jpg', // Path to logo image
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
                                builder: (context) => ProfilePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 40,
                ),
                // Voice Control Slider (Sleek Circular Slider)
                Center(
                  child: Column(
                    children: [
                      // Voice icon
                      Icon(Icons.volume_up, size: 40, color: Colors.black),
                      SizedBox(height: 20),

                      // Circular Slider
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

                      // MIN and MAX Labels
                      Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  deviceWidth * 0.25, 0, 0, 0),
                              child: Text(
                                'MIN',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  deviceWidth * 0.15, 0, 0, 0),
                              child: Text(
                                'MAX',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Text reading
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Text Reading",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: isTextReadingEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isTextReadingEnabled = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      // Face Recognition
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Face Recognition",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: isFaceRecognitionEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isFaceRecognitionEnabled = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 100),

                // Start Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        buttonTitle = buttonTitle == "START" ? "STOP" : "START";
                      });
                      // Handle Start button press
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(400, 60),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 100),
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
}
