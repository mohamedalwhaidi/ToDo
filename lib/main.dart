import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/auth/login.dart';

import 'todo/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  Widget homeScreen = HomeScreen();
  if (user == null) {
    homeScreen = LoginScreen();
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoApp(homeScreen),
    ),
  );
}

class ToDoApp extends StatelessWidget {
  final Widget home;

  ToDoApp(this.home);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: this.home,
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.teal,
      ),
    );
  }
}
