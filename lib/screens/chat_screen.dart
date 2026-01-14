import 'package:flutter/material.dart';
import 'inbox.dart';
import 'reveal_profile.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String personName;
  final String chatId;
  const ChatScreen({super.key, required this.personName, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // Profile data for reveal functionality
  final Map<String, Map<String, dynamic>> _profileData = {
    'person1': {
      'name': 'Anna, 24',
      'location': 'Athens',
      'bio': 'Loves books, hiking, and good coffee. Always up for a spontaneous adventure or a cozy café morning.',
      'interests': ['Books', 'Hiking', 'Coffee', 'Travel', 'Art'],
      'compatibility': 0.8,
    },
    'person2': {
      'name': 'Maria, 27',
      'location': 'Thessaloniki',
      'bio': 'Art lover, movie buff, and foodie. I believe in living life to the fullest and enjoying every moment.',
      'interests': ['Art', 'Movies', 'Food', 'Photography', 'Music'],
      'compatibility': 0.6,
    },
    'person3': {
      'name': 'Eleni, 22',
      'location': 'Patras',
      'bio': 'Enjoys gaming, music, and spending time with pets. Looking for someone who gets my gamer side.',
      'interests': ['Gaming', 'Music', 'Pets', 'Technology', 'Anime'],
      'compatibility': 0.9,
    },
    'person4': {
      'name': 'Sofia, 29',
      'location': 'Crete',
      'bio': 'Traveler, gym enthusiast, and social butterfly. Let\'s explore new places and try new experiences together.',
      'interests': ['Travel', 'Gym', 'Social', 'Cooking', 'Outdoors'],
      'compatibility': 0.7,
    },
  };

  @override
  void initState() {
    super.initState();
    _messages = _chatHistories[widget.chatId] ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentUser = StorageService.getLoggedInUser();
    if (currentUser == null) return;

    // Add message to local UI
    setState(() {
      _messages.add({'sender': 'me', 'text': text});
      _chatHistories[widget.chatId] = _messages;
      _controller.clear();
    });

    // Save message to Hive storage
    await StorageService.sendMessage(currentUser, widget.personName, text);

    // Simulate a response (optional)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'other',
            'text': 'Thanks for the message! I\'ll get back to you soon 😊'
          });
        });
      }
    });
  }

  void _revealProfile() {
    final profile = _profileData[widget.chatId];
    if (profile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RevealProfileScreen(
            personName: profile['name'],
            location: profile['location'],
            bio: profile['bio'],
            interests: List<String>.from(profile['interests']),
            compatibility: profile['compatibility'],
            chatId: widget.chatId,
          ),
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
        child: Stack(
          children: [
            // Top bar with name and prev button
            Positioned(
              top: 20,
              left: 20,
              child: SizedBox(
                width: 77,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB7CD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const InboxScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'PREV',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF633B48),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.personName,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Reveal button
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB7CD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: _revealProfile,
                  child: const Text(
                    'Reveal Profile',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF633B48),
                    ),
                  ),
                ),
              ),
            ),
            // Chat messages
            Positioned.fill(
              top: 170,
              bottom: 70,
              child: ListView.builder(
                itemCount: _messages.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, idx) {
                  final msg = _messages[idx];
                  final isMe = msg['sender'] == 'me';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFFFB7CD) : const Color(0xFF633B48),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: isMe ? const Color(0xFF633B48) : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Message input
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF633B48).withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFFFFB7CD)),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simulated persistent chat history (replace with real storage in production)
final Map<String, List<Map<String, String>>> _chatHistories = {};
