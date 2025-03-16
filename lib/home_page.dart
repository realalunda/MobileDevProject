import 'dart:async'; // สำหรับ Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'transfer_page.dart'; // Import TransferPage
import 'topup_page.dart'; // Import TopUpPage
import 'transaction_page.dart'; // Import TransactionPage
import 'user_profile_page.dart'; // Import UserProfilePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0; // สำหรับติดตามแท็บที่เลือก
  final PageController _pageController =
      PageController(); // สำหรับเลื่อน Promotion
  late Timer _timer; // Timer สำหรับเลื่อนอัตโนมัติ

  @override
  void initState() {
    super.initState();

    // ตั้งค่า Timer สำหรับเลื่อนอัตโนมัติ
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % 5; // 5 คือจำนวนรูป
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // ยกเลิก Timer เมื่อหน้า HomePage ถูกปิด
    _pageController.dispose(); // ปิด PageController
    super.dispose();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TransferPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TopUpPage(addBalance: addBalance)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserProfilePage()), // Navigate to UserProfilePage
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Function to add balance
  void addBalance(double amount) {
    User? user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'balance': FieldValue.increment(amount),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
      );
    }

    // Check if the app is in dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // กำหนดความสูงของ AppBar ให้เล็กลง
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // ทำให้มุมล่างของ AppBar โค้งมน
          ),
          child: AppBar(
            automaticallyImplyLeading: false, // Disable the back arrow
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          const Color.fromARGB(255, 255, 255, 255),
                          Colors.orangeAccent
                        ] // Match light mode gradient
                      : [
                          const Color.fromARGB(255, 255, 255, 255),
                          Colors.orangeAccent
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ), // สีพื้นหลังของ AppBar
            title: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle, // Change shape to rectangle
                ),
                child: Image.network(
                  'https://vectorseek.com/wp-content/uploads/2023/12/TrueMoney-Logo-Vector.svg-1-1.png',
                  // URL ของโลโก้แอพ
                  width: 170,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userDoc = snapshot.data!;
          if (!userDoc.exists) {
            return Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          // แปลง balance เป็น double
          double balance = (userDoc['balance'] as num).toDouble();
          String email = userDoc['email'] ?? "No Email";

          // เนื้อหาของแต่ละแท็บ
          final List<Widget> _pages = [
            // หน้าแรก (Home)
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 120,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TopUpPage(addBalance: addBalance),
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.9, // ปรับความกว้างให้ยาวขึ้น
                                height: 100,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      offset: Offset(4, 4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet,
                                              size: 15,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                          SizedBox(width: 5),
                                          Text('Wallet >',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Balance:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          Text(
                                              '฿${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Email:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          Text(email,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text('Promotion Shop',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          Container(
                            height: 175,
                            child: PageView(
                              controller: _pageController,
                              children: [
                                Image.network(
                                  'https://www.getamped.in.th/wp-content/uploads/2022/03/promotion-truemoney-mar2022.jpg',
                                  fit: BoxFit.cover,
                                ),
                                Image.network(
                                  'https://www.truemoney.com/wp-content/uploads/2021/07/truemoneywallet_promotion_banner_15072021.jpeg',
                                  fit: BoxFit.cover,
                                ),
                                Image.network(
                                  'https://www.truemoney.com/wp-content/uploads/2022/11/KKP-Start-saving-banner-20221102-1100x550-1.jpg',
                                  fit: BoxFit.cover,
                                ),
                                Image.network(
                                  'https://th.bing.com/th/id/OIP.7rTt52uGX7IH5_5dw8_0TwHaHa?rs=1&pid=ImgDetMain',
                                  fit: BoxFit.cover,
                                ),
                                Image.network(
                                  'https://th.bing.com/th/id/OIP.D4Xp8oeeICKpNLP8exOkDgHaHa?rs=1&pid=ImgDetMain',
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text('Investment',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          SizedBox(height: 15),
                          SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    offset: Offset(4, 4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recommended Stocks',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.trending_up,
                                              color: Colors.blue),
                                          title: Text('TSLA',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                          subtitle: Text('Tesla Inc.',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          trailing: Text(
                                            '\$800.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.trending_up,
                                              color: Colors.blue),
                                          title: Text('AMZN',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                          subtitle: Text('Amazon.com Inc.',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          trailing: Text(
                                            '\$3,200.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.trending_up,
                                              color: Colors.blue),
                                          title: Text('NFLX',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                          subtitle: Text('Netflix Inc.',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          trailing: Text(
                                            '\$500.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.trending_up,
                                              color: Colors.blue),
                                          title: Text('NVDA',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                          subtitle: Text('NVIDIA Corp.',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          trailing: Text(
                                            '\$600.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.trending_up,
                                              color: Colors.blue),
                                          title: Text('FB',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                          subtitle: Text('Meta Platforms Inc.',
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black)),
                                          trailing: Text(
                                            '\$350.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];

          return _pages[_selectedIndex];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionPage()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.history, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange, // Set selected color to orange
        unselectedItemColor: Colors.grey, // Set unselected color to grey
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
            icon: Icon(Icons.person), // Add user profile icon
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
