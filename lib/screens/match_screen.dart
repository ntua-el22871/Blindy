import 'package:flutter/material.dart';
import 'dart:math';
import 'inbox.dart';
import 'view_profile.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Anna, 24',
      'location': 'Athens',
      'bio': 'Loves books, hiking, and good coffee.',
      'interests': ['Books', 'Hiking', 'Coffee'],
      'compatibility': 0.8,
    },
    {
      'name': 'Maria, 27',
      'location': 'Thessaloniki',
      'bio': 'Art lover, movie buff, and foodie.',
      'interests': ['Art', 'Movies', 'Food'],
      'compatibility': 0.6,
    },
    {
      'name': 'Eleni, 22',
      'location': 'Patras',
      'bio': 'Enjoys gaming, music, and pets.',
      'interests': ['Gaming', 'Music', 'Pets'],
      'compatibility': 0.9,
    },
    {
      'name': 'Sofia, 29',
      'location': 'Crete',
      'bio': 'Traveler, gym enthusiast, and social.',
      'interests': ['Travel', 'Gym', 'Social'],
      'compatibility': 0.7,
    },
  ];
  int _currentIndex = 0;
  final Random _random = Random();
  final List<int> _history = [];

  void _nextProfile({bool random = false}) {
    setState(() {
      _history.add(_currentIndex);
      if (random) {
        int newIndex;
        do {
          newIndex = _random.nextInt(_profiles.length);
        } while (newIndex == _currentIndex && _profiles.length > 1);
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

  void _onInterested() {
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
    final profile = _profiles[_currentIndex];
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
                    Center(
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
                              profile['name'],
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
                              profile['location'],
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
                          profile['bio'],
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
                          children: List.generate(
                            (profile['interests'] as List).length,
                            (i) => Chip(
                              label: Text(
                                profile['interests'][i],
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
                                value: profile['compatibility'],
                                minHeight: 12,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6171)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(profile['compatibility'] * 100).toInt()}%',
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
