import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(VisiosenseApp());
}

class VisiosenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangePassword(),
    );
  }
}

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Add your background image path here
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
                  Image.asset(
                    'assets/forgetpassword.png', // Placeholder for waveform image
                    height: 100,
                  ),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your password must be at least 6 characters and should include a combination of numbers, letters and special characters (!@%)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Current Password',
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
                      String currentPassword = currentPasswordController.text;
                      String newPassword = newPasswordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      if (currentPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Current password must be provided.'),
                        ));
                        return;
                      }

                      if (newPassword == confirmPassword) {
                        try {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            final email = user.email;

                            // Re-authenticate the user
                            AuthCredential credential = EmailAuthProvider.credential(email: email!, password: currentPassword);
                            await user.reauthenticateWithCredential(credential);

                            // Update password in Firebase Authentication
                            await user.updatePassword(newPassword);

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
                                  .doc(userDoc.id)
                                  .update({'Password': newPassword});

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Password updated successfully!'),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('No user found with the provided email address.'),
                              ));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No user is currently signed in.'),
                            ));
                          }
                        } catch (e) {
                          print("Error updating password: ${e.toString()}");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to update password.'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Passwords do not match.'),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('CHANGE PASSWORD'),
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
