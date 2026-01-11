import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BlindyApp());
}
class BlindyApp extends StatelessWidget {
  const BlindyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blindy',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
