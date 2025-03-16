import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truemoney/user_profile_page.dart';
import 'home_page.dart';
import 'topup_page.dart';

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 1; // ตั้งค่าเริ่มต้นให้เป็นหน้า Transfer

  Future<String?> getUserUIDByEmail(String email) async {
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id; // คืนค่า UID
      }
    } catch (e) {
      print("Error fetching UID: $e");
    }
    return null; // ถ้าไม่เจอผู้ใช้
  }

  Future<void> _transferMoney() async {
    double amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    String receiverEmail = _emailController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณากรอกจำนวนเงินที่ถูกต้อง")),
      );
      return;
    }

    User? sender = _auth.currentUser;
    if (sender == null) return;

    if (receiverEmail == sender.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ไม่สามารถโอนเงินเข้าบัญชีตัวเองได้")),
      );
      return;
    }

    DocumentReference senderDoc =
        _firestore.collection('Users').doc(sender.uid);
    DocumentSnapshot senderSnapshot = await senderDoc.get();

    if (!senderSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ไม่พบข้อมูลบัญชีของคุณ")),
      );
      return;
    }

    double senderBalance = (senderSnapshot['balance'] as num).toDouble();
    if (senderBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ยอดเงินไม่เพียงพอ")),
      );
      return;
    }

    String? receiverUID = await getUserUIDByEmail(receiverEmail);
    if (receiverUID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ไม่พบผู้รับ")),
      );
      return;
    }

    DocumentReference receiverDoc =
        _firestore.collection('Users').doc(receiverUID);
    DocumentSnapshot receiverSnapshot = await receiverDoc.get();

    if (!receiverSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ไม่พบข้อมูลบัญชีผู้รับ")),
      );
      return;
    }

    String senderEmail = senderSnapshot['email'] ?? "Unknown Sender";
    String receiverEmailFromDB =
        receiverSnapshot['email'] ?? "Unknown Receiver";

    await _firestore.runTransaction((transaction) async {
      transaction.update(senderDoc, {
        'balance': FieldValue.increment(-amount),
      });
      transaction.update(receiverDoc, {
        'balance': FieldValue.increment(amount),
      });
      transaction.set(_firestore.collection('transactions').doc(), {
        'senderId': sender.uid,
        'senderEmail': senderEmail, // เก็บอีเมลของผู้โอน
        'receiverId': receiverUID,
        'receiverEmail': receiverEmailFromDB, // เก็บอีเมลของผู้รับ
        'amount': amount,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [sender.uid, receiverUID], // เก็บผู้เข้าร่วม
      });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("โอนเงินสำเร็จ!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return '';
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  bool _isTransferButtonEnabled() {
    double? amount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    return _emailController.text.isNotEmpty &&
        amount != null &&
        amount > 0 &&
        amount <= 500000;
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
      // Do nothing because we are already on the TransferPage
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TopUpPage(addBalance: (double amount) {
                  // Implement the logic to add balance here
                })),
      );
    } else if (index == 3) {
      // Add logic for Profile tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfilePage()), // Navigate to ProfilePage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transfer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ปิดการแสดงลูกศรย้อนกลับ
        title: Text(
          'Transfer',
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('Users').doc(user.uid).snapshots(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "ยอดเงินคงเหลือ: ฿${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'อีเมลผู้รับ',
                    hintText: 'example@example.com',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20),
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
                    labelText: 'จำนวนเงิน',
                    hintText: '฿ 00.00',
                    border: OutlineInputBorder(),
                    helperText: 'ไม่เกิน 500,000',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  maxLength: 140,
                  decoration: InputDecoration(
                    labelText: 'ข้อความ (0/140)',
                    hintText: 'กรอกข้อความถึงผู้รับ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isTransferButtonEnabled() ? _transferMoney : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'โอนเงิน',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white), // Updated text color to white
                  ),
                ),
              ],
            ),
          );
        },
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
