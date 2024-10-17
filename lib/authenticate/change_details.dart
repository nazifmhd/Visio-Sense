import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VisiosenseApp());
}

class VisiosenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian',
      home: ChangeDetailsScreen(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
    );
  }
}

class ChangeDetailsScreen extends StatefulWidget {
  @override
  _ChangeDetailsScreenState createState() => _ChangeDetailsScreenState();
}

class _ChangeDetailsScreenState extends State<ChangeDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Firebase instance
  final CollectionReference guardianCollection =
      FirebaseFirestore.instance.collection('guardians');

  // Method to calculate score
  int _calculateScore() {
    int score = 0;

    if (_firstNameController.text.isNotEmpty) {
      score++;
    }

    if (_lastNameController.text.isNotEmpty) {
      score++;
    }

    if (_phoneNumberController.text.isNotEmpty &&
        _phoneNumberController.text.length >= 10) {
      score++;
    }

    if (_addressController.text.isNotEmpty) {
      score++;
    }

    return score;
  }

  // Method to show score dialog
  void _showScoreDialog(int score) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Form Score'),
          content: Text('Your score is $score/4'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to update guardian data in Firestore
  Future<void> _updateGuardianData() async {
    try {
      await guardianCollection.add({
        'First Name': _firstNameController.text,
        'Last Name': _lastNameController.text,
        'Address': _addressController.text,
        'Phone Number': _phoneNumberController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Guardian details updated successfully!'),
      ));
    } catch (e) {
      print("Error updating guardian data: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update guardian details.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 94, 93, 93),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Do you need to Change Details?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              // First Name
              SizedBox(height: 30),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),

              // Last Name
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),

              // Address
              SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),

              // Phone Number Field using IntlPhoneField
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
                initialCountryCode: 'LK', // Default country code
                onChanged: (phone) {
                  _phoneNumberController.text = phone.completeNumber;
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

              // Confirm Button
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      int score = _calculateScore();
                      _showScoreDialog(score);

                      // Update Firestore with new data
                      _updateGuardianData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'CONFIRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
