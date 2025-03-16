import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController =
      TextEditingController(); // New controller for name

  Future<void> register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'balance': 0, // Default balance
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow
        title: Center(
          child: Text(
            "Welcome", // Change title to Welcome
            style: TextStyle(
              color: Colors.deepOrange, // สีข้อความ deep orange
              fontWeight: FontWeight.bold, // ตัวหนา
            ),
          ),
        ),
        backgroundColor: Colors.white, // สี AppBar เป็นสีขาวล้วน
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Colors.grey[900]!, Colors.black]
                    : [
                        const Color.fromARGB(255, 255, 255, 255),
                        Colors.orangeAccent
                      ], // Adjust gradient for dark mode
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5, // ครึ่งหน้าจอ
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [Colors.grey[900]!, Colors.black]
                      : [
                          Colors.orangeAccent,
                          Colors.deepOrange
                        ], // Adjust gradient for dark mode
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50.0), // มุมโค้งมนด้านบน
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // เงาสีดำจางๆ
                    blurRadius: 10.0, // ความเบลอของเงา
                    offset: Offset(0, -5), // ตำแหน่งเงา
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://vectorseek.com/wp-content/uploads/2023/12/TrueMoney-Logo-Vector.svg-1-1.png', // URL ของโลโก้
                  width: MediaQuery.of(context).size.width *
                      0.6, // ความกว้าง 60% ของหน้าจอ
                ),
                SizedBox(height: 30), // ระยะห่างระหว่างโลโก้กับกล่อง register
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // ความกว้าง 90% ของหน้าจอ
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white, // Adjust container color for dark mode
                    borderRadius: BorderRadius.circular(50.0), // มุมโค้งมนมากๆ
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // เงาสีดำจางๆ
                        blurRadius: 10.0, // ความเบลอของเงา
                        offset: Offset(0, 5), // ตำแหน่งเงา
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ขนาดตามเนื้อหา
                    children: [
                      Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 24, // ขนาดตัวอักษร
                          fontWeight: FontWeight.bold, // ตัวหนา
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange
                              : Colors
                                  .deepOrange, // Adjust text color for dark mode
                        ),
                      ),
                      SizedBox(height: 20), // ระยะห่างระหว่างข้อความกับฟิลด์
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white, // Adjust background for dark mode
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: nameController, // Name input field
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors
                                      .black, // Adjust label color for dark mode
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey[800]
                                : Colors
                                    .white, // Adjust fill color for dark mode
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors
                                    .black, // Adjust text color for dark mode
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white, // Adjust background for dark mode
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors
                                      .black, // Adjust label color for dark mode
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey[800]
                                : Colors
                                    .white, // Adjust fill color for dark mode
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors
                                    .black, // Adjust text color for dark mode
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white, // Adjust background for dark mode
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors
                                      .black, // Adjust label color for dark mode
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey[800]
                                : Colors
                                    .white, // Adjust fill color for dark mode
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors
                                    .black, // Adjust text color for dark mode
                          ),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepOrange, // ปุ่มสี deep orange
                          foregroundColor: Colors.white, // ข้อความสีขาว
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold, // ตัวหนา
                          ),
                        ),
                        child: Text("Register"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(
                              color:
                                  Colors.deepOrange), // ข้อความสี deep orange
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
