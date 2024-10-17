import 'package:flutter/material.dart';
import 'package:visiosense/authenticate/signup_user.dart';
import 'package:visiosense/models/Guardian_User-Data.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  runApp(VisioSenseApp());
}

class VisioSenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpGuardian(),
    );
  }
}

class SignUpGuardian extends StatefulWidget {
  const SignUpGuardian({super.key});

  @override
  State<SignUpGuardian> createState() => SignUpGuardianState();
}

class SignUpGuardianState extends State<SignUpGuardian> {
  final _formKey = GlobalKey<FormState>();
  final GuardianUserDataService _guardianUserDataService =
      GuardianUserDataService();
  String gfirstName = "";
  String glastName = "";
  String gaddress = "";
  String gphoneNumber = "";

  Map<String, String> guardianData = {};

  // Function to handle form submission
  Future<void> _submitFormAndNavigator() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        // Add guardian data to Firestore
        guardianData = {
          'gfirstName': gfirstName,
          'glastName': glastName,
          'gaddress': gaddress,
          'gphoneNumber': gphoneNumber,
        };

        // Navigate to the SignUpUser screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpUser({
              'gfirstName': gfirstName,
              'glastName': glastName,
              'gaddress': gaddress,
              'gphoneNumber': gphoneNumber,
            }),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error adding guardian: $e')));
      }
    }
  }

  // Flutter UI with validation
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: deviceHeight * 0.09),
                Text(
                  "Welcome to Visio Sense",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: deviceWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Guardian Container
                Container(
                  width: deviceWidth * 0.9,
                  height: deviceHeight * 0.1,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Register as Guardian',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
                Center(
                  child: Image.asset(
                    'assets/wave.png', // Centered image
                    height: deviceHeight * 0.20,
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // First Name and Last Name Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (val) => val?.isEmpty == true
                                  ? "Enter your first name"
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  gfirstName = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'First Name',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: deviceWidth * 0.05),
                          Expanded(
                            child: TextFormField(
                              validator: (val) => val?.isEmpty == true
                                  ? "Enter your last name"
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  glastName = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Last Name',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: deviceHeight * 0.02),

                      // Address Field
                      TextFormField(
                        validator: (val) =>
                            val?.isEmpty == true ? "Enter your address" : null,
                        onChanged: (val) {
                          setState(() {
                            gaddress = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Address',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),

                      // Phone Number Field with IntlPhoneField
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        initialCountryCode: 'LK', // Default country code
                        onChanged: (phone) {
                          setState(() {
                            gphoneNumber = phone.completeNumber;
                          });
                        },
                        validator: (val) {
                          if (val == null || val.completeNumber == null) {
                            return "Enter a valid phone number";
                          } else if (val.completeNumber.length < 9) {
                            return "Phone number is too short";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: deviceHeight * 0.02),

                      // OK Button
                      ElevatedButton(
                        onPressed: _submitFormAndNavigator,
                        style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(deviceWidth * 0.9, deviceHeight * 0.08),
                          padding: EdgeInsets.symmetric(
                              vertical: deviceHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: deviceWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
