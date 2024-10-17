import 'package:flutter/material.dart';

void main() {
  runApp(Language());
}

class Language extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LanguageScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LanguageScreen extends StatelessWidget {
  // List of languages and their associated flags
  final List<Map<String, String>> languages = [
    {"name": "English", "flag": "🇬🇧"},
    {"name": "Sinhala", "flag": "🇱🇰"},
    {"name": "Japanese", "flag": "🇯🇵"},
    {"name": "Arabic", "flag": "🇦🇪"},
    {"name": "Tamil", "flag": "🇮🇳"},
    {"name": "French", "flag": "🇫🇷"},
    {"name": "Russian", "flag": "🇷🇺"},
    {"name": "Spanish", "flag": "🇪🇸"},
  ];

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
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(220),
                child: AppBar(
                  backgroundColor: Colors.grey[700],
                  title: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns per row
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio:
                          1.0, // Reduced the aspect ratio to give more vertical space
                    ),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      return LanguageCard(
                        language: languages[index]["name"]!,
                        flag: languages[index]["flag"]!,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LanguageCard extends StatelessWidget {
  final String language;
  final String flag;

  LanguageCard({required this.language, required this.flag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle language selection action
        print('Selected Language: $language');
      },
      child: Card(
        elevation: 6,
        margin: EdgeInsets.all(12.0),
        child: Padding(
          padding: EdgeInsets.all(15.0), // Reduced padding to give more space
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Text(
                  flag,
                  style: TextStyle(
                    fontSize: 45, // Reduced flag font size
                  ),
                ),
              ),

              SizedBox(height: 10), // Reduced spacing
              FittedBox(
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 18, // Reduced language font size
                    fontWeight: FontWeight.bold,
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
