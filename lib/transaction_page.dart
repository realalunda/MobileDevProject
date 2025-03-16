import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transactions',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepOrangeAccent,
          iconTheme:
              IconThemeData(color: Colors.white), // เปลี่ยนสีไอคอนเป็นสีขาว
        ),
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        iconTheme:
            IconThemeData(color: Colors.white), // เปลี่ยนสีไอคอนเป็นสีขาว
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('transactions')
            .where('participants', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child:
                    Text("เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('TopUpTransactions')
                .where('email', isEqualTo: user.email)
                .snapshots(),
            builder: (context, topUpSnapshot) {
              if (topUpSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (topUpSnapshot.hasError) {
                return Center(
                    child: Text(
                        "เกิดข้อผิดพลาดในการโหลดข้อมูล: ${topUpSnapshot.error}"));
              }

              var transactions = snapshot.data?.docs ?? [];
              var topUpTransactions = topUpSnapshot.data?.docs ?? [];

              if (transactions.isEmpty && topUpTransactions.isEmpty) {
                return Center(child: Text("ไม่มีรายการธุรกรรมหรือการเติมเงิน"));
              }

              var allTransactions = [...transactions, ...topUpTransactions];
              allTransactions.sort((a, b) {
                Timestamp timeA = a['timestamp'] ?? Timestamp(0, 0);
                Timestamp timeB = b['timestamp'] ?? Timestamp(0, 0);
                return timeB.compareTo(timeA);
              });

              if (allTransactions.isEmpty) {
                return Center(child: Text("ไม่มีรายการธุรกรรม"));
              }

              return ListView.builder(
                itemCount: allTransactions.length,
                itemBuilder: (context, index) {
                  var transaction = allTransactions[index];
                  bool isTopUp =
                      transaction.reference.parent.id == 'TopUpTransactions';

                  return ListTile(
                    leading: Icon(
                      isTopUp
                          ? Icons.add_circle
                          : transaction['senderId'] == user.uid
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                      color: isTopUp
                          ? Colors.blue
                          : transaction['senderId'] == user.uid
                              ? const Color.fromARGB(255, 255, 0, 0)
                              : const Color.fromARGB(255, 2, 128, 0),
                    ),
                    title: Text(
                      isTopUp
                          ? "เติมเงิน: ฿${transaction['amount'].toStringAsFixed(2)}"
                          : transaction['senderId'] == user.uid
                              ? "โอนไปยัง: ${transaction['receiverEmail']}"
                              : "ได้รับจาก: ${transaction['senderEmail']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isTopUp
                          ? "เวลา: ${(transaction['timestamp'] as Timestamp).toDate().toString().split('.')[0]}"
                          : "จำนวนเงิน: ฿${transaction['amount'].toStringAsFixed(2)}",
                    ),
                    trailing: Text(
                      transaction['timestamp'] != null
                          ? (transaction['timestamp'] as Timestamp)
                              .toDate()
                              .toString()
                              .split('.')[0]
                          : "ไม่ระบุเวลา",
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(isTopUp
                                ? "รายละเอียดการเติมเงิน"
                                : "รายละเอียดธุรกรรม"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isTopUp)
                                  Text("ผู้โอน: ${transaction['senderEmail']}",
                                      style: TextStyle(fontSize: 16)),
                                if (!isTopUp)
                                  Text(
                                      "ผู้รับ: ${transaction['receiverEmail']}",
                                      style: TextStyle(fontSize: 16)),
                                Text(
                                    "จำนวนเงิน: ฿${transaction['amount'].toStringAsFixed(2)}",
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                  "เวลา: ${transaction['timestamp'] != null ? (transaction['timestamp'] as Timestamp).toDate().toString().split('.')[0] : "ไม่ระบุเวลา"}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                if (isTopUp)
                                  Text(
                                      "ธนาคาร: ${transaction['bankName'] ?? "ไม่ระบุธนาคาร"}",
                                      style: TextStyle(fontSize: 16)),
                                if (isTopUp)
                                  Text(
                                      "อีเมล: ${transaction['email'] ?? "ไม่ระบุอีเมล"}",
                                      style: TextStyle(fontSize: 16)),
                                if (!isTopUp)
                                  Text(
                                      "ข้อความ: ${transaction['message'] != null && transaction['message'] != "" ? transaction['message'] : "ไม่มีข้อความ"}",
                                      style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("ปิด",
                                    style: TextStyle(color: Colors.deepOrange)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
