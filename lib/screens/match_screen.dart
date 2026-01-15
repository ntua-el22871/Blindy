import 'package:flutter/material.dart';
import 'dart:math';

// Imports των άλλων οθονών
import 'view_profile.dart'; 
import 'chat_screen.dart'; 
import 'login_screen.dart'; 

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = StorageService.getLoggedInUser();
      
      // Παίρνουμε τα δεδομένα (μπορεί να είναι dynamic)
      final rawProfiles = await StorageService.getAllProfiles();
      
      // --- ΔΙΟΡΘΩΣΗ ΓΙΑ ΤΟ TYPE ERROR (Screenshot 2) ---
      // Μετατρέπουμε ρητά κάθε στοιχείο σε Map<String, dynamic>
      final List<Map<String, dynamic>> safeProfiles = rawProfiles.map((profile) {
        return Map<String, dynamic>.from(profile as Map);
      }).toList();

      if (mounted) {
        setState(() {
          _profiles = safeProfiles;
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

  // --- LOGOUT FUNCTION ---
  void _logout() {
    // Πλοήγηση στο Login και διαγραφή του ιστορικού
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _nextProfile({bool random = false}) {
    if (_profiles.isEmpty) return;
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

      await StorageService.likeProfile(_currentUser!, profileId);
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profiles.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF3131), Color(0xFFBD5656), Color(0xFFDA3838), Color(0xFFFF0000)],
              stops: [0.0, 0.2067, 0.7452, 1.0],
            ),
          ),
          child: Stack(
            children: [
               // Logout Button όταν είναι άδεια η λίστα
               Positioned(
                top: 60, right: 24,
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white, size: 32),
                ),
               ),
               const Center(child: Text("No profiles found", style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
    }

    final profile = _profiles[_currentIndex];
    final List interests = (profile['interests'] as List? ?? []);
    final double compatibility = (profile['compatibility'] as num? ?? 0).toDouble();

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _onNotInterested();
            } else if (details.primaryVelocity! > 0) {
              _onInterested();
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
              colors: [Color(0xFFFF3131), Color(0xFFBD5656), Color(0xFFDA3838), Color(0xFFFF0000)],
              stops: [0.0, 0.2067, 0.7452, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // --- TOP BAR ---
              Positioned(
                top: 60, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Icon (Left)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
                          );
                        },
                        child: const Icon(Icons.person_outline, color: Colors.white, size: 32),
                      ),
                      
                      // Title (Center)
                      const Text(
                        'Matches',
                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 40, color: Colors.white),
                      ),
                      
                      // Chat & Logout Icons (Right)
                      Row(
                        children: [
                          GestureDetector(
                            // --- ΔΙΟΡΘΩΣΗ ΓΙΑ ΤΟ CHAT SCREEN (Screenshot 5) ---
                            // Επειδή το ChatScreen σου ζητάει ορίσματα, δίνουμε dummy τιμές
                            // για να ανοίξει η σελίδα χωρίς errors.
                            onTap: () {
                               Navigator.of(context).push(
                                 MaterialPageRoute(
                                   builder: (context) => const ChatScreen(
                                     personName: "Inbox", // Ή βάλε "Matches"
                                     chatId: "general_inbox",
                                   ),
                                 ),
                               );
                            },
                            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16), 
                          GestureDetector(
                            onTap: _logout,
                            child: const Icon(Icons.logout, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- MATCH CARD ---
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 80),
                  width: 360,
                  height: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC31A36),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.black12, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Row(
                          children: [
                            Text(profile['name'] ?? 'Unknown', style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white)),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(profile['location'] ?? 'Unknown', style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Text('Bio:', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white.withOpacity(0.9))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Text(profile['bio'] ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Text('Interests:', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white.withOpacity(0.9))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Wrap(
                          spacing: 8, runSpacing: 4,
                          children: List.generate(interests.length, (i) => Chip(label: Text(interests[i].toString(), style: const TextStyle(color: Color(0xFF633B48))), backgroundColor: Colors.white)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          children: [
                            Expanded(child: LinearProgressIndicator(value: compatibility, minHeight: 12, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6171)), borderRadius: BorderRadius.circular(8))),
                            const SizedBox(width: 12),
                            Text('${(compatibility * 100).toInt()}%', style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28), onPressed: _prevProfile),
                            IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 32), onPressed: _onNotInterested),
                            IconButton(icon: const Icon(Icons.favorite, color: Color(0xFFFF6171), size: 32), onPressed: _onInterested),
                            IconButton(icon: const Icon(Icons.refresh, color: Colors.white, size: 28), onPressed: _onRefresh),
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

// --- MOCK DATA / Storage Service ---
// Αν έχεις δικό σου αρχείο storage_service.dart, ΣΒΗΣΕ ΤΗΝ ΠΑΡΑΚΑΤΩ ΚΛΑΣΗ
// και κάνε uncomment το import στην κορυφή.
class StorageService {
  static String getLoggedInUser() => "user123";
  static Future<List<dynamic>> getAllProfiles() async {
    return [
      {'id': '1', 'name': 'Maria', 'age': '24', 'location': 'Athens', 'bio': 'Coffee & Art.', 'interests': ['Art', 'Coffee'], 'compatibility': 0.85},
      {'id': '2', 'name': 'Eleni', 'age': '22', 'location': 'Thessaloniki', 'bio': 'Hiking lover.', 'interests': ['Hiking', 'Pets'], 'compatibility': 0.65}
    ];
  }
  static Future<void> likeProfile(String u, String p) async {}
  static bool checkMatch(String u, String p) => true; 
}