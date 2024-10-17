import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visiosense/authenticate/reset_password.dart';

class Verification extends StatelessWidget {
  final String otp; // Receives the OTP passed from the previous screen

  // TextEditingController is used to manage the input from the text fields
  // Separate controllers are used for each of the 4 OTP input boxes
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();

  Verification(
      {required this.otp}); // Constructor to receive the OTP from the previous interface

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter the OTP sent to your Email Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // Spreads out the input boxes evenly
                    children: [
                      _buildCodeBox(otpController1), // First OTP input box
                      _buildCodeBox(otpController2), // Second OTP input box
                      _buildCodeBox(otpController3), // Third OTP input box
                      _buildCodeBox(otpController4), // Fourth OTP input box
                    ],
                  ),
                  SizedBox(height: 10), // Adds space before the verify button
                  // Button to verify the entered OTP
                  ElevatedButton(
                    onPressed: () {
                      // Combine the values from the 4 input boxes into a single string
                      String enteredOtp = otpController1.text +
                          otpController2.text +
                          otpController3.text +
                          otpController4.text;

                      // Check if the entered OTP matches the one passed to this screen
                      if (enteredOtp == otp) {
                        // OTP is correct, navigate to the Reset Password screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResetPassword()), // Navigates to the ResetPassword screen
                        );
                      } else {
                        // OTP is incorrect, display an error message
                        Fluttertoast.showToast(
                          msg: "Incorrect OTP",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      backgroundColor: Colors.black,
                    ),
                    child: const Text('VERIFY'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build individual OTP input boxes
  Widget _buildCodeBox(TextEditingController controller) {
    return Container(
      width: 50, // Fixed width for the input box
      height: 50, // Fixed height for the input box
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black), // Adds a black border around the box
        borderRadius: BorderRadius.circular(8), // Rounds the corners of the box
      ),
      child: Center(
        child: TextField(
          controller: controller, // Controller that manages the text input
          textAlign: TextAlign.center, // Centers the entered text
          keyboardType: TextInputType.number, // Allows only numeric input
          maxLength: 1, // Restricts input to a single character
          decoration: InputDecoration(
            border: InputBorder.none, // Removes the default border
            counterText:
                '', // Removes the character counter below the input box
          ),
        ),
      ),
    );
  }
}
