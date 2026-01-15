import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'match_screen.dart';
import 'profile_creation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;

  void _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    bool success;
    if (_isRegistering) {
      success = await StorageService.registerUser(username, password);
      if (success && mounted) {
        // Save logged in user and go to profile creation
        await StorageService.saveLoggedInUser(username);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(username: username)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Username exists?')));
      }
    } else {
      success = await StorageService.loginUser(username, password);
      if (success && mounted) {
        // Check if profile is completed
        final userProfiles = StorageService.appData.get('userProfiles') ?? {};
        final userProfile = userProfiles[username] ?? {};
        
        if (userProfile['profileCompleted'] == true) {
          // Profile is complete, go to match screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MatchScreen()),
          );
        } else {
          // Profile is incomplete, go to profile creation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProfileCreationScreen(username: username)),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong username or password')));
      }
    }
  }

  void _clearDatabase() async {
    await StorageService.clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database Cleared! Create users again.')),
      );
    }
  }

  void _setupTestUsers() async {
    bool user1 = await StorageService.registerUser('alice', 'password123');
    if (!user1) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User alice already exists')));
      return;
    }

    bool user2 = await StorageService.registerUser('bob', 'password123');
    if (!user2) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User bob already exists')));
      return;
    }

    await StorageService.updateProfile('alice', {
      'id': 'alice',
      'name': 'Alice',
      'age': '25',
      'gender': 'Female',
      'location': 'Athens',
      'bio': 'Love coffee and hiking 🏔️',
      'interests': ['Coffee', 'Hiking', 'Reading']
    });

    await StorageService.updateProfile('bob', {
      'id': 'bob',
      'name': 'Bob',
      'age': '27',
      'gender': 'Male',
      'location': 'Athens',
      'bio': 'Adventure seeker and photographer 📸',
      'interests': ['Photography', 'Hiking', 'Travel']
    });

    await StorageService.likeProfile('bob');
    await StorageService.saveLoggedInUser('bob');
    await StorageService.likeProfile('alice');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test users created! alice & bob match! Try: alice (pwd: password123)'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF3131),
              Color(0xFFBD5656),
              Color(0xFFDA3838),
              Color(0xFFFF0000),
            ],
            stops: [0.0, 0.2067, 0.7452, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                const SizedBox(height: 40),
                Text(
                  'Blindy',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 57,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Find connection beyond looks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Color(0xFFD9D9D9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 60),

                // Title
                Text(
                  _isRegistering ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegistering 
                    ? 'Join our community'
                    : 'Sign in to continue finding connections',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Username field
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username or Email',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    child: Text(
                      _isRegistering ? 'Create Account' : 'Sign In',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF3131),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Toggle registration
                GestureDetector(
                  onTap: () => setState(() => _isRegistering = !_isRegistering),
                  child: RichText(
                    text: TextSpan(
                      text: _isRegistering ? 'Already have an account? ' : "Don't have an account? ",
                      style: const TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: _isRegistering ? 'Log In' : 'Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _setupTestUsers,
            backgroundColor: Colors.green,
            tooltip: 'Create test users (alice & bob)',
            heroTag: 'add_users',
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _clearDatabase,
            backgroundColor: Colors.grey,
            tooltip: 'Clear database',
            heroTag: 'clear_db',
            child: const Icon(Icons.delete_forever, color: Colors.white),
          ),
        ],
      ),
    );
  }
}