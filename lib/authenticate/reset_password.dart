import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visiosense/authenticate/signin.dart';

void main() {
  runApp(VisioSenseApp());
}

class VisioSenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResetPassword(),
    );
  }
}

class ResetPassword extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/resetpasswordnew.png', // Placeholder for waveform image
            height: 100,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Background image path
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
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Set the new password for your account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'so you can login and access all the features',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      String email = emailController.text;
                      String newPassword = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      if (newPassword == confirmPassword) {
                        try {
                          // Query Firestore to find the document with the given email
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('Guardian_User-Data')
                              .where('Email', isEqualTo: email)
                              .get();

                          // Check if any document was found
                          if (querySnapshot.docs.isNotEmpty) {
                            // Get the document (assuming email is unique)
                            DocumentSnapshot userDoc = querySnapshot.docs.first;

                            // Update password in Firestore using the document ID
                            await FirebaseFirestore.instance
                                .collection('Guardian_User-Data')
                                .doc(userDoc
                                    .id) // Use the ID of the found document
                                .update({
                              'Password':
                                  newPassword, // Update the password field
                            });

                            Fluttertoast.showToast(
                              msg: "Password updated successfully",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            // Redirect to login screen
                            Future.delayed(Duration(seconds: 2), () {
                              // Navigator.popUntil(
                              //     context, ModalRoute.withName('/login'));

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SignInScreen()), // Replace Login with your login component
                                (Route<dynamic> route) =>
                                    false, // This predicate removes all the previous routes
                              );
                            });
                          } else {
                            // Show error message if no user found
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'No user found with this email address.'),
                            ));
                          }
                        } catch (error) {
                          print("Failed to update password: $error");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Error updating password. Please try again.'),
                          ));
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "Passwords do not match.",
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
                    child: const Text('RESET PASSWORD'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
