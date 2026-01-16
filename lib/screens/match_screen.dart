import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'inbox.dart';
import 'view_profile.dart';
import 'profile_creation_screen.dart';
import 'login_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<Map<String, dynamic>> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadProfiles();
  }

  void _checkProfileCompletion() {
    final loggedInUser = StorageService.getLoggedInUser();
    if (loggedInUser != null) {
      final userProfiles = StorageService.appData.get('userProfiles') ?? {};
      final userProfile = userProfiles[loggedInUser] ?? {};
      
      if (userProfile['profileCompleted'] != true) {
        // Profile incomplete, redirect to profile creation
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(username: loggedInUser)),
        );
      }
    }
  }

  void _loadProfiles() {
    final profiles = StorageService.getProfilesToSwipe();
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  void _onSwipe(bool liked) async {
    if (_profiles.isEmpty) return;
    
    final currentProfile = _profiles[_currentIndex];
    
    if (liked) {
      await StorageService.likeProfile(currentProfile['id']);
      bool isMatch = StorageService.checkMatch(currentProfile['id']);
      if (isMatch && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("It's a Match with ${currentProfile['name']}! 🎉"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
          // Additional notification for new message from dummy accounts
          if (currentProfile['id'] == 'alice' || currentProfile['id'] == 'bob') {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You have a new message from ${currentProfile['name']}! 💬"),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          }
        }
      }

    setState(() {
      _profiles.removeAt(_currentIndex);
      if (_profiles.isNotEmpty) {
        _currentIndex %= _profiles.length;
      }
    });
  }

  void _logout() async {
    await StorageService.logoutUser();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF3131), Color(0xFFFF0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white, size: 28),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
                      ),
                    ),
                    const Text(
                      "Blindy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                      color: const Color(0xFF633B48),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'messages',
                          child: Row(
                            children: const [
                              Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Messages', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Inbox()),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'logout',
                          onTap: _logout,
                          child: Row(
                            children: const [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Logout', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Card or No Matches Message
              Expanded(
                child: Center(
                  child: _profiles.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, color: Colors.white, size: 64),
                            const SizedBox(height: 16),
                            const Text(
                              'There are no matches left',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Inbox()),
                              ),
                              icon: const Icon(Icons.favorite),
                              label: const Text('View Your Matches'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF3131),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: 520,
                          width: 340,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildProfileCard(),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final profile = _profiles[_currentIndex];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile info
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${profile['age'] ?? '?'} • ${profile['location'] ?? 'Unknown'}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile['bio'] ?? '',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              // Interests
              if (profile['interests'] != null && (profile['interests'] as List).isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['interests'] as List)
                      .map((interest) => Chip(
                        label: Text(interest.toString()),
                        backgroundColor: const Color(0xFFFFB7CD),
                        labelStyle: const TextStyle(
                          color: Color(0xFF633B48),
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                      .toList(),
                ),
            ],
          ),
        ),
        const Spacer(),
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => _onSwipe(false),
                backgroundColor: Colors.grey[300],
                heroTag: 'dislike',
                child: const Icon(Icons.close, color: Colors.red, size: 28),
              ),
              FloatingActionButton(
                onPressed: () => _onSwipe(true),
                backgroundColor: Colors.green[300],
                heroTag: 'like',
                child: const Icon(Icons.favorite, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}