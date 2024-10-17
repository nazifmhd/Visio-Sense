import 'package:flutter/material.dart';
import 'package:visiosense/authenticate/change_password.dart';
import 'package:visiosense/authenticate/about_app_page.dart';
import 'package:visiosense/authenticate/terms_and_conditions.dart';
import 'package:visiosense/authenticate/privacy_policy.dart';
import 'package:visiosense/authenticate/change_details.dart';
import 'package:visiosense/authenticate/history.dart';
import 'package:visiosense/authenticate/language.dart';
import 'package:visiosense/models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserService userService = UserService();
    Map<String, dynamic>? userData = await userService.fetchUserData();

    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? ''; // Fetch name
        userEmail = userData['email'] ?? ''; // Fetch email
      });
    } else {
      print("No user data found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back button
            },
          ),
          title: Text('Profile'),
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 137, 136, 136),
        ),
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

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty
                                  ? userName
                                  : 'Loading...', // Display user's name
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userEmail.isNotEmpty
                                  ? userEmail
                                  : 'Loading...', // Display user's email
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Handle profile edit
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),

                  // General Settings
                  ListTile(
                    title: Text('Change Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeDetailsScreen()));
                      // Handle details change
                    },
                  ),

                  ListTile(
                    title: Text('Change Password',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePassword()));
                      // Handle password change
                    },
                  ),

                  ListTile(
                    title: Text('Language',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LanguageScreen()));
                      // Handle language change
                    },
                  ),

                  ListTile(
                    title: Text('History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryScreen()));
                      // Handle history view
                    },
                  ),

                  Divider(),

                  // Information Section
                  ListTile(
                    title: Text('About App',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutAppPage()));
                      // Navigate to About App
                    },
                  ),

                  ListTile(
                    title: Text('Terms & Conditions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage()));
                      // Navigate to Terms & Conditions
                    },
                  ),

                  ListTile(
                    title: Text('Privacy Policy',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage()));
                      // Navigate to Privacy Policy
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
