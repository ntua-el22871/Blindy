import 'package:flutter/material.dart';
import 'match_screen.dart'; // Import για το StorageService
import 'chat_screen.dart';  // Import για το Chat

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  List<Map<String, String>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    // Καλούμε τη μέθοδο από το StorageService
    final matches = await StorageService.getMatches();
    
    if (mounted) {
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
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
        child: Stack(
          children: [
            // Τίτλος
            Positioned(
              top: 60, left: 0, right: 0,
              child: Center(
                child: Text(
                  'Matches',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 40,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.25), offset: const Offset(0, 4), blurRadius: 4)],
                  ),
                ),
              ),
            ),
            
            // Λίστα
            Positioned.fill(
              top: 140, bottom: 0,
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _matches.isEmpty 
                      ? const Center(child: Text("No matches yet!", style: TextStyle(color: Colors.white, fontSize: 18)))
                      : ListView.builder(
                          itemCount: _matches.length,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemBuilder: (context, idx) {
                            final chat = _matches[idx];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  // Εδώ περνάμε τα ορίσματα που ζητάει το ChatScreen σου
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        personName: chat['name']!,
                                        chatId: chat['chatId']!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF633B48),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(chat['name']!, style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white)),
                                          ),
                                          Icon(Icons.location_on, color: Colors.white.withOpacity(0.7), size: 16),
                                          const SizedBox(width: 4),
                                          Text(chat['location']!, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white.withOpacity(0.7))),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(color: const Color(0xFFFFD8E4), borderRadius: BorderRadius.circular(12)),
                                        child: Text(chat['lastMessage']!, style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 13, color: Color(0xFF633B48)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            
            // Κουμπί Πίσω
            Positioned(
              top: 20, left: 20,
              child: SizedBox(
                width: 77, height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB7CD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MatchScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('PREV', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF633B48))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}