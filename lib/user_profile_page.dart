import 'package:flutter/material.dart';
import 'package:truemoney/home_page.dart';
import 'package:truemoney/topup_page.dart';
import 'package:truemoney/transfer_page.dart';
import 'main.dart'; // Import to access themeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truemoney/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:truemoney/edit_user_screen.dart'; // Import EditUserScreen
import 'package:truemoney/help_and_support_page.dart'; // Import HelpAndSupportPage

class UserProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> _getUserStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('Users').doc(user.uid).snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('User Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Add rounded corners to the bottom
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepOrangeAccent,
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Name: ${userData['name'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: ${userData['email'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditUserScreen()), // Navigate to EditUserScreen
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text('Edit Profile',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: Text('Dark Mode'),
                        secondary: Icon(Icons.brightness_6,
                            color: Colors.deepOrangeAccent),
                        value: themeNotifier.value == ThemeMode.dark,
                        activeColor: const Color.fromARGB(
                            255, 242, 243, 242), // Set active color to green
                        activeTrackColor: Colors.deepOrange
                            .withOpacity(1), // Consistent active track
                        inactiveTrackColor: Colors.grey
                            .withOpacity(1), // Consistent inactive track
                        visualDensity: VisualDensity
                            .compact, // Make the toggle button smaller
                        onChanged: (bool value) {
                          themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.help, color: Colors.deepOrangeAccent),
                        title: Text('Help & Support'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HelpAndSupportPage()), // Navigate to HelpAndSupportPage
                          );
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.logout, color: Colors.deepOrangeAccent),
                        title: Text('Logout'),
                        onTap: () async {
                          await FirebaseAuth.instance
                              .signOut(); // Sign out the user
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage()), // Navigate to login page
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Set the current index to Profile
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TransferPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TopUpPage(addBalance: (amount) {
                        // Add logic to handle balance addition
                      })),
            );
          }
        },
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Top Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
