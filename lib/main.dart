import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

// Add a ValueNotifier to manage theme state
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Kanit',
            brightness: Brightness.light,
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange),
              ),
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Kanit',
            brightness: Brightness.dark,
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange),
              ),
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          themeMode: currentTheme,
          home: LoginPage(),
        );
      },
    );
  }
}
