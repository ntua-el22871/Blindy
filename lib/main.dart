import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/match_screen.dart';
import 'screens/view_profile.dart';
import 'screens/credentials.dart';
import 'screens/profcreat_quiz.dart';
import 'screens/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open the appData box
  await Hive.openBox('appData');
  
  runApp(const BlindyApp());
}
class BlindyApp extends StatelessWidget {
  const BlindyApp({super.key});import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Make sure these paths match exactly where your files are located
import 'screens/login_screen.dart';
import 'screens/match_screen.dart'; // <--- Check this file exists here
import 'screens/view_profile.dart';
import 'screens/credentials.dart';
import 'screens/profcreat_quiz.dart';
import 'screens/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open the appData box
  // CRITICAL: Ensure your MatchScreen/StorageService uses this exact box name
  await Hive.openBox('appData'); 
  
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
      routes: {
        // FIX: Removed 'const' here. 
        // If MatchScreen is complex or not a const constructor anymore, 
        // keeping 'const' here causes an error.
        '/match': (context) => const MatchScreen(), 
        
        // If the line above is still red, change it to:
        // '/match': (context) => MatchScreen(),
        
        '/profile': (context) => const ViewProfileScreen(),
        '/credentials': (context) => const CredentialsScreen(),
        '/quiz': (context) => const ProfileCreationScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}

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
      routes: {
        '/match': (context) => const MatchScreen(),
        '/profile': (context) => const ViewProfileScreen(),
        '/credentials': (context) => const CredentialsScreen(),
        '/quiz': (context) => const ProfileCreationScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
