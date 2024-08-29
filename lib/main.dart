import 'package:flutter/material.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sign In & Sign Up',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SignInScreen(),
      routes: {
        '/sign-up': (context) => SignUpScreen(),
      },
    );
  }
}
