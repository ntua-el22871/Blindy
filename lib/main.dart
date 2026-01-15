import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Imports των οθονών σου
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
      // Η αρχική οθόνη
      home: const LoginScreen(),
      
      // Τα routes για την πλοήγηση
      routes: {
        // ΠΡΟΣΟΧΗ: Αν κάποια οθόνη δεν είναι const (π.χ. παίρνει ορίσματα),
        // αφαίρεσε το 'const' από μπροστά της.
        '/match': (context) => const MatchScreen(),
        '/profile': (context) => const ViewProfileScreen(), 
        '/credentials': (context) => const CredentialsScreen(),
        '/quiz': (context) => const ProfileCreationScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}