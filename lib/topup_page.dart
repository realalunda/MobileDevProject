import 'package:flutter/material.dart';
import 'package:truemoney/user_profile_page.dart';
import 'home_page.dart';
import 'transfer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopUpPage extends StatefulWidget {
  final Function(double) addBalance;

  TopUpPage({required this.addBalance});

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  int _selectedIndex = 2; // ตั้งค่าเริ่มต้นให้เป็นหน้า Top Up
  String? _selectedBank; // ตัวแปรสำหรับเก็บธนาคารที่เลือก

  final List<Map<String, String>> _banks = [
    {
      'name': 'BBL',
      'logo':
          'https://th.bing.com/th/id/OIP.AxjX0g2CROC_DAoq03PKiAHaKF?rs=1&pid=ImgDetMain'
    },
    {
      'name': 'KBANK',
      'logo':
          'https://th.bing.com/th/id/OIP.1WKOFsePNfPfaqeKTyJ3yAHaHZ?rs=1&pid=ImgDetMain'
    },
    {
      'name': 'KTB',
      'logo':
          'https://th.bing.com/th/id/OIP.LWd-WqG_dsVVPu-v_ynPIwHaGK?rs=1&pid=ImgDetMain'
    },
    {
      'name': 'SCB',
      'logo':
          'https://th.bing.com/th/id/OIP.ZCZ2KUONKgtustJ8FSnHogHaHU?rs=1&pid=ImgDetMain'
    },
    {
      'name': 'TTB',
      'logo': 'https://www.iphone-droid.net/wp-content/uploads/2023/12/ttb.jpg'
    },
    {
      'name': 'GSB',
      'logo':
          'https://th.bing.com/th/id/OIP.IhXqEUyicJCspxhHWFppgAHaHa?rs=1&pid=ImgDetMain'
    },
    {
      'name': 'BAY',
      'logo':
          'https://s3-symbol-logo.tradingview.com/bank-of-ayudhya-public-company-limited--600.png'
    },
    {
      'name': 'CIMBT',
      'logo':
          'https://www.cimbthai.com/content/dam/cimb/personal/images/global/CIMB_logo.png'
    },
  ];

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return '';
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
      // Do nothing because we are already on the TopUpPage
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ensure back arrow is hidden
        title: Text(
          'Top Up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          ClipOval(
            child: Image.network(
              'https://is3-ssl.mzstatic.com/image/thumb/Purple125/v4/c8/e5/d7/c8e5d7a0-e6cb-1e94-20f1-e678c2a38e91/source/512x512bb.jpg', // Replace with your image URL
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10), // Add spacing between the image and the edge
        ],
        backgroundColor: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Add rounded corners to the bottom
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เลือกธนาคาร',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Increase number of logos per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _banks.length,
              itemBuilder: (context, index) {
                final bank = _banks[index];
                final isSelected = _selectedBank == bank['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBank = bank['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? Colors.deepOrangeAccent : Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(bank['logo']!, width: 40, height: 40),
                        SizedBox(height: 3),
                        Text(
                          bank['name']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text('จำนวนเงิน (บาท)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                String formatted = _formatNumber(value);
                if (formatted != value) {
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _amountController.clear();
                    setState(() {});
                  },
                ),
                helperText: 'ไม่เกิน 500,000',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_selectedBank != null &&
                      (_amountController.text.isNotEmpty &&
                          double.tryParse(
                                  _amountController.text.replaceAll(',', '')) !=
                              null &&
                          double.parse(
                                  _amountController.text.replaceAll(',', '')) <=
                              500000))
                  ? () async {
                      double amount = double.tryParse(
                              _amountController.text.replaceAll(',', '')) ??
                          0;

                      // Get current user
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        String email = user.email ?? '';

                        // Reference to Firestore
                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;

                        // Update balance in Users collection
                        DocumentReference userDoc =
                            firestore.collection('Users').doc(user.uid);
                        await firestore.runTransaction((transaction) async {
                          DocumentSnapshot snapshot =
                              await transaction.get(userDoc);
                          if (snapshot.exists) {
                            double currentBalance =
                                snapshot['balance']?.toDouble() ?? 0.0;
                            double updatedBalance = currentBalance + amount;

                            transaction.update(userDoc, {
                              'balance': updatedBalance,
                            });

                            // Add top-up transaction to a new collection
                            await firestore
                                .collection('TopUpTransactions')
                                .add({
                              'amount': amount,
                              'balance': updatedBalance,
                              'timestamp': FieldValue.serverTimestamp(),
                              'email': email,
                              'bankName':
                                  _selectedBank, // Add selected bank name
                            });
                          }
                        });
                      }

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    }
                  : null, // ปิดปุ่มถ้าไม่มีธนาคารหรือจำนวนเงินไม่ถูกต้อง
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                minimumSize: Size(double.infinity, 50), // ปุ่มขนาดใหญ่
              ),
              child: Text('เติมเงิน',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'มีปัญหาโปรดติดต่อเรา',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor:
                Colors.deepOrange, // Set selected color to orange
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
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
