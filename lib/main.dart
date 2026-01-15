import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Imports των οθονών σου (Όπως τα είχες)
import 'screens/login_screen.dart';
import 'screens/match_screen.dart';
import 'screens/view_profile.dart';
import 'screens/credentials.dart';
import 'screens/profcreat_quiz.dart';
import 'screens/sign_up_screen.dart';
// import 'screens/inbox.dart'; // Αν χρειαστείς route και για το inbox

void main() async {
  // Εξασφαλίζουμε ότι τα Widgets έχουν φορτώσει
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Αρχικοποίηση Hive
  await Hive.initFlutter();
  
  // 2. Άνοιγμα του κουτιού 'appData' (ΕΔΩ αποθηκεύονται οι users και τα matches)
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
        // Το κόκκινο χρώμα της εφαρμογής σου
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3131),
          primary: const Color(0xFFFF3131),
        ),
        useMaterial3: true,
      ),
      
      // Η αρχική οθόνη
      home: const LoginScreen(),
      
      // Τα routes για την πλοήγηση (ώστε να δουλεύει το pushNamed('/signup') κλπ)
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