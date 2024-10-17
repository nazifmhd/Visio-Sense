import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visiosense/authenticate/forget_password.dart';
import 'package:visiosense/authenticate/start_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiosense/authenticate/signup_guardian.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInState();
}

class SignInState extends State<SignInScreen> {
  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Email and password fields
  String email = "";
  String password = "";
  String error = "";
  bool rememberMe = false;

  bool _obscureText = true;

  // Sign in with email and password
  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() == true) {
      if (!rememberMe) {
        setState(() {
          error = "Please check 'Remember Me' to proceed.";
        });
        return; // Exit if Remember Me is not checked
      }
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StartPage()),
        );
      } catch (e) {
        setState(() {
          error = "Invalid email or password.";
        });
      }
    } else {
      setState(() {
        error = "Please enter a valid email and password.";
      });
    }
  }

  // Sign in with Google
  void _launchURL() async {
    const url = 'https://accounts.google.com/signin';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: deviceWidth,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: deviceHeight * 0.1),
              Text(
                "Hello, Guest!",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: deviceWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: deviceHeight * 0.01),
              Text(
                "Welcome to Visio Sense",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: deviceWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: deviceHeight * 0.01),
              Text(
                "Before Continue, Please Sign in First.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/wave.jpg', // Centered image
                  height: deviceHeight * 0.20,
                ),
              ),
              // Email input
              TextFormField(
                validator: (val) =>
                    val?.isEmpty == true ? "Enter a valid email" : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: deviceWidth * 0.05,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 193, 191, 191),
                ),
              ),
              SizedBox(height: deviceHeight * 0.02),

              // Password input with toggle visibility
              TextFormField(
                validator: (val) => val != null && val.length < 6
                    ? "Enter a valid Password"
                    : null,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: deviceWidth * 0.05,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 193, 191, 191),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Toggle visibility
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: deviceHeight * 0.01),

              // Remember Me and Forgot Password row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (newValue) {
                          setState(() {
                            rememberMe = newValue!;
                          });
                        },
                      ),
                      Text(
                        "Remember Me",
                        style: TextStyle(
                          fontSize: deviceWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPassword()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: deviceWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: deviceHeight * 0.03),

              // Error message if any
              if (error.isNotEmpty)
                Text(
                  error,
                  style: TextStyle(
                      color: Colors.red, fontSize: deviceWidth * 0.045),
                ),
              SizedBox(height: deviceHeight * 0.01),

              // Sign In button
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(deviceWidth * 0.9, deviceHeight * 0.08),
                  padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "SIGN IN",
                  style: TextStyle(
                    fontSize: deviceWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: deviceHeight * 0.02),

              // Sign Up option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: deviceWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpGuardian()),
                      );
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: deviceWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: deviceHeight * 0.02),

              // Divider for alternate sign-in options
              Center(
                child: Text(
                  '_OR_',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: deviceHeight * 0.02),

              // Google Sign In Button
              Center(
                child: GestureDetector(
                  onTap: _launchURL,
                  child: Image.asset(
                    'assets/google.jpg',
                    width: deviceWidth * 0.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
