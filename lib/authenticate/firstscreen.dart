import 'package:flutter/material.dart';
import 'dart:async';
import 'package:visiosense/authenticate/signin.dart';

void main() async {
  runApp(VisiosenseApp());
}

class VisiosenseApp extends StatelessWidget {
  const VisiosenseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;
  double blindImageScale = 1.5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _animation2 = Tween<double>(begin: 1.2, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _timer = Timer(Duration(seconds: 2), () {
      _controller.forward(); // Start the scaling animation after 3 seconds
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  //flutter inerface
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Visio Sense title (unchanged)
                    Text(
                      'Visio Sense',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 10),
                    // Subtitle (unchanged)
                    Text(
                      'Mobile Vision Enhancer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),

                    SizedBox(height: 5),
                    Image.asset(
                      'assets/wave.png',
                      height: 200,
                    ),

                    SizedBox(height: 2),
                    // Blind person image (shrinks after 3 seconds)
                    Padding(
                      padding: EdgeInsets.only(right: deviceWidth * 0.2),
                      child: Transform.scale(
                        scale: _animation
                            .value, // Adjust the scale factor as needed
                        child: Image.asset(
                          'assets/blind.png',
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Transform.scale(
                      scale: _animation2.value,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(300, 55),
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black // Button color
                            ),
                        child: Text(
                          'GET STARTED',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    // Show Sign In button after 3 seconds
                    // if (_showSignInButton)
                    //   ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => SignInScreen()));
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //         fixedSize: Size(300, 50),
                    //         padding: EdgeInsets.symmetric(
                    //             vertical: 15, horizontal: 80),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         foregroundColor: Colors.white,
                    //         backgroundColor: Colors.black // Button color
                    //         ),
                    //     child: Text(
                    //       'SIGN IN',
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold, fontSize: 24),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
