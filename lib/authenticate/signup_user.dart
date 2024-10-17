import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visiosense/authenticate/signin.dart';
import 'package:visiosense/models/Guardian_User-Data.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  runApp(VisiosenseApp());
}

class VisiosenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, String> guardianData = {
      'gfirstName': '',
      'glastName': '',
      'gaddress': '',
      'gphoneNumber': '',
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpUser(guardianData),
    );
  }
}

class SignUpUser extends StatefulWidget {
  final Map<String, String> guardianData;
  const SignUpUser(this.guardianData, {super.key});

  @override
  State<SignUpUser> createState() => SignUpUserState();
}

class SignUpUserState extends State<SignUpUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GuardianUserDataService _guardianUserDataService =
      GuardianUserDataService();
  final _formKey = GlobalKey<FormState>();

  String firstName = "";
  String lastName = "";
  String email = "";
  String phoneNumber = "";
  String createPassword = "";
  String confirmPassword = "";
  String error = "";
  bool _obscureCreatePassword = true;
  bool _obscureConfirmPassword = true;
  bool termsAccepted = false;

  // Access guardian data from the widget
  Map<String, String> get guardianData => widget.guardianData;

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() == true && termsAccepted) {
      if (createPassword == confirmPassword) {
        try {
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email,
            password: createPassword,
          );

          // Save user data in Firestore using UserDataService
          await _guardianUserDataService.addGuardianUserData(
            userCredential.user!.uid,
            firstName,
            lastName,
            email,
            phoneNumber,
            createPassword,
            guardianData['gfirstName']!,
            guardianData['glastName']!,
            guardianData['gaddress']!,
            guardianData['gphoneNumber']!,
          );

          // Navigate to the SignUpScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        } catch (e) {
          setState(() {
            error = "Error: ${e.toString()}";
          });
        }
      } else {
        setState(() {
          error = "Passwords do not match.";
        });
      }
    }else if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please accept the terms and conditions.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: 400,
                      height: 100,
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'User',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // First Name
                    SizedBox(height: 100),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (val) => val?.isEmpty == true
                                ? "Enter your first name"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                firstName = val;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),

                        // Last Name
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            validator: (val) => val?.isEmpty == true
                                ? "Enter your last name"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                lastName = val;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Email
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) =>
                          val?.isEmpty == true ? "Enter a valid email" : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    // Phone Number
                    SizedBox(height: 20),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      initialCountryCode: 'LK',
                      onChanged: (phone) {
                        setState(() {
                          phoneNumber = phone.completeNumber;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.completeNumber.isEmpty) {
                          return "Enter a valid Phone Number";
                        } else if (val.completeNumber.length < 9) {
                          return "Phone number is too short";
                        }
                        return null;
                      },
                    ),

                    // Create Password
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) => val != null && val.length < 8
                          ? "Enter a valid Password"
                          : null,
                      onChanged: (val) {
                        setState(() {
                          createPassword = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Create your Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCreatePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCreatePassword = !_obscureCreatePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureCreatePassword,
                    ),

                    // Confirm Password
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val != createPassword) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          confirmPassword = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                    ),

                    // Display error message
                    SizedBox(height: 20),
                    if (error.isNotEmpty)
                      Text(
                        error,
                        style: TextStyle(color: Colors.red),
                      ),

                    SizedBox(height: 5),
                    Row(
                      children: [
                        Checkbox(
                          value: termsAccepted,
                          onChanged: (newValue) {
                            setState(() {
                              termsAccepted = newValue!;
                            });
                          },
                        ),
                        const Text('I agree to the '),
                        GestureDetector(
                          onTap: () {
                            // Handle Terms and Conditions tap
                          },
                          child: const Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(400, 60),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('OK'),
                    ),
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
