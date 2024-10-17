import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visiosense/authenticate/verification.dart';
import 'package:mailer/mailer.dart'; // Import the mailer package
import 'package:mailer/smtp_server.dart'; // Import for using SMTP server
import 'dart:math'; // For generating random OTP
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgetPassword(),
    );
  }
}

class ForgetPassword extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Background image path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Centered content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/forgetpassword.png',
                      height: 250,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  // White Container for text only
                  Container(
                    width: 800,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(2, 2), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Subtitle
                        Text(
                          'Enter the email address associated with your account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80),

                  // Email TextField (outside the container)
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 80),

                  // Send Button (outside the container)
                  ElevatedButton(
                    onPressed: () async {
                      String enteredEmail = emailController.text;

                      // Step 1: Check if the email exists in Firestore
                      FirebaseFirestore.instance
                          .collection(
                              'Guardian_User-Data') // Collection in Firestore
                          .where('Email',
                              isEqualTo:
                                  enteredEmail) // Query for matching email
                          .get()
                          .then((querySnapshot) async {
                        if (querySnapshot.docs.isNotEmpty) {
                          // Step 2: If email is found, generate the OTP
                          String otp = generateOtp();

                          // Step 3: Call Firebase Cloud Function to send the OTP email
                          try {
                            final HttpsCallable callable = FirebaseFunctions
                                .instance
                                .httpsCallable('sendOtpEmail');
                            await callable.call({
                              'email': enteredEmail, // Pass the entered email
                              'otp': otp, // Pass the generated OTP
                            });
                            // Log success message
                            Fluttertoast.showToast(
                              msg: "OTP sent successfully",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Verification(
                                    otp: otp,
                                  ),
                                ),
                              );
                            });
                          } catch (error) {
                            // Log any error during the OTP sending process
                            print('Error sending OTP: $error');
                          }
                        } else {
                          // If email is not found in the database, show error
                          print("Email not found in database");
                        }
                      }).catchError((error) {
                        // Log any error during the email checking process
                        print("Error checking email: $error");
                      });
                    },
                    // Button styling
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(400, 60), // Set button size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded button corners
                      ),
                      backgroundColor: Colors.black, // Set button color
                    ),
                    // Button text
                    child: const Text(
                      'SEND',
                      style: TextStyle(fontSize: 16), // Set text size
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to generate a random 4-digit OTP
  String generateOtp() {
    var random = Random(); // Create a random number generator
    return (random.nextInt(9000) + 1000)
        .toString(); // Generates a 4-digit OTP (between 1000 and 9999)
  }

  // Function to send the OTP via Gmail SMTP
  Future<void> sendOtpEmail(String email, String otp) async {
    String username = 'visiosense123@gmail.com'; // Your Gmail address
    String password = 'xnvajwayxyruacah'; // Your Gmail App Password

    // Configure Gmail SMTP server
    final smtpServer = gmail(username, password);

    // Create email message with OTP
    final message = Message()
      ..from = Address(username, 'Your App Name') // Sender's email
      ..recipients.add(email) // Recipient's email
      ..subject = 'Password Reset OTP' // Email subject
      ..text = 'Your OTP code is $otp'; // Email body with OTP

    try {
      // Log attempt to send email
      print("Attempting to send email to: $email with OTP: $otp");
      // Send the email
      final sendReport = await send(message, smtpServer);
      // Log success
      print('OTP sent successfully: ' + sendReport.toString());
    } catch (e) {
      // Log failure to send OTP
      print('Failed to send OTP: $e');
    }
  }
}
