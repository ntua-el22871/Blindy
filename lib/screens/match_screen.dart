import 'package:flutter/material.dart';
import 'dart:math';

// --- INSTRUCTIONS ---
// If you have your own files for these, uncomment your imports
// and delete the dummy classes at the bottom of this file.
// import 'inbox.dart';
// import 'view_profile.dart';
// import '../services/storage_service.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<Map<String, dynamic>> _profiles = [];
  int _currentIndex = 0;
  final Random _random = Random();
  final List<int> _history = [];
  String? _currentUser;
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      // Simulate network/database delay if necessary
      // await Future.delayed(const Duration(milliseconds: 500));

      // Get current user
      _currentUser = StorageService.getLoggedInUser();

      // Load profiles from storage
      // FIX: Ensure we await if this is an async call in your real service
      final profiles = await StorageService.getAllProfiles();

      if (mounted) {
        setState(() {
          _profiles = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profiles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextProfile({bool random = false}) {
    if (_profiles.isEmpty) return; // FIX: Prevent crash on empty list

    setState(() {
      _history.add(_currentIndex);
      if (random && _profiles.length > 1) {
        int newIndex;
        do {
          newIndex = _random.nextInt(_profiles.length);
        } while (newIndex == _currentIndex);
        _currentIndex = newIndex;
      } else {
        _currentIndex = (_currentIndex + 1) % _profiles.length;
      }
    });
  }

  void _prevProfile() {
    setState(() {
      if (_history.isNotEmpty) {
        _currentIndex = _history.removeLast();
      }
    });
  }

  void _onInterested() async {
    if (_currentUser != null && _profiles.isNotEmpty) {
      final currentProfile = _profiles[_currentIndex];
      final profileId = currentProfile['id'] ?? _currentIndex.toString();

      // Like the profile
      await StorageService.likeProfile(_currentUser!, profileId);

      // Check if it's a match
      bool isMatch = StorageService.checkMatch(_currentUser!, profileId);
      
      if (isMatch && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('It\'s a Match! 🎉'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    _nextProfile();
  }

  void _onNotInterested() {
    _nextProfile();
  }

  void _onRefresh() {
    _nextProfile(random: true);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Handle Loading State
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Handle Empty State
    if (_profiles.isEmpty) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: Text("No profiles found", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    final profile = _profiles[_currentIndex];
    
    // FIX: Null safety variables
    final List interests = (profile['interests'] as List? ?? []);
    // Ensure compatibility is a double, handling integers or nulls safely
    final double compatibility = (profile['compatibility'] as num? ?? 0).toDouble();

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _onNotInterested(); // Swipe Left
            } else if (details.primaryVelocity! > 0) {
              _onInterested(); // Swipe Right
            }
          }
        },
        child: Container(
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
          child: Stack(
            children: [
              // Top bar with chat icon
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ViewProfileScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Matches',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const InboxScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Match card
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 80),
                  width: 360,
                  height: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC31A36),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.black12, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Row(
                          children: [
                            Text(
                              profile['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              profile['location'] ?? 'Unknown',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Text(
                          'Bio:',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Text(
                          profile['bio'] ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Text(
                          'Interests:',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4, // Added runSpacing for multiple lines
                          children: List.generate(
                            interests.length,
                            (i) => Chip(
                              label: Text(
                                interests[i].toString(),
                                style: const TextStyle(color: Color(0xFF633B48)),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: compatibility,
                                minHeight: 12,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6171)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(compatibility * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                              onPressed: _prevProfile,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 32),
                              onPressed: _onNotInterested,
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Color(0xFFFF6171), size: 32),
                              onPressed: _onInterested,
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                              onPressed: _onRefresh,
                            ),
                          ],
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
    );
  }
}

// ==========================================================
// MOCK CLASSES (Remove these if you have real files)
// ==========================================================

class StorageService {
  static String getLoggedInUser() => "current_user_123";

  // Simulating Async data fetch
  static Future<List<Map<String, dynamic>>> getAllProfiles() async {
    return [
      {
        'id': '1',
        'name': 'Sarah',
        'location': 'New York',
        'bio': 'Love photography and traveling the world.',
        'interests': ['Photography', 'Travel', 'Art'],
        'compatibility': 0.85,
      },
      {
        'id': '2',
        'name': 'Mike',
        'location': 'London',
        'bio': 'Coffee enthusiast and tech geek.',
        'interests': ['Coding', 'Coffee', 'Gaming'],
        'compatibility': 0.65,
      },
       {
        'id': '3',
        'name': 'Jessica',
        'location': 'Paris',
        'bio': 'Chef at a local bistro.',
        'interests': ['Cooking', 'Wine', 'Music'],
        'compatibility': 0.92,
      },
    ];
  }

  static Future<void> likeProfile(String user, String profileId) async {
    print("User $user liked profile $profileId");
  }

  static bool checkMatch(String user, String profileId) {
    // Randomly return true for demo purposes
    return Random().nextBool(); 
  }
}

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("My Profile")));
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Inbox")));
  }
}