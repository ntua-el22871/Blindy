import 'package:flutter/material.dart';
import 'match_screen.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {'name': 'Anna, 24', 'lastMessage': 'You: Hello!', 'chatId': 'person1', 'location': 'Athens'},
      {'name': 'Maria, 27', 'lastMessage': 'Maria: Hey there!', 'chatId': 'person2', 'location': 'Thessaloniki'},
      {'name': 'Eleni, 22', 'lastMessage': 'You: Nice to meet you', 'chatId': 'person3', 'location': 'Patras'},
      {'name': 'Sofia, 29', 'lastMessage': 'Sofia: Let\'s chat!', 'chatId': 'person4', 'location': 'Crete'},
    ];

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
            // Title
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Inbox',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 40,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Chats List
            Positioned.fill(
              top: 140,
              bottom: 0,
              child: ListView.builder(
                itemCount: chats.length,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemBuilder: (context, idx) {
                  final chat = chats[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name with location
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat['name']!,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chat['location']!,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Last message
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD8E4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat['lastMessage']!,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color: Color(0xFF633B48),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Previous button
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
                        builder: (context) => const MatchScreen(),
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
          ],
        ),
      ),
    );
  }
}
