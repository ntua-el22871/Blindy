import 'package:flutter/material.dart';
import 'inbox.dart';

class ChatScreen extends StatefulWidget {
  final String personName;
  final String chatId;
  const ChatScreen({super.key, required this.personName, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const int messageLimit = 50; // ~2-3 days of chatting
  List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  int get messageCount => _messages.length;
  bool get canReveal => messageCount >= messageLimit;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    // Load chat history from local storage or memory (for demo, just keep in memory)
    // TODO: Implement persistent storage for real app
    // For now, simulate with static map
    _messages = _chatHistories[widget.chatId] ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'me', 'text': text});
      _chatHistories[widget.chatId] = _messages;
      _controller.clear();
    });
  }

  void _reveal() {
    if (canReveal) {
      setState(() {
        _revealed = true;
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
            // Reveal button and message bar
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canReveal ? const Color(0xFFFFB7CD) : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: canReveal ? _reveal : null,
                    child: Text(
                      _revealed ? 'Revealed!' : 'Reveal',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Color(0xFF633B48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD8E4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Messages sent: $messageCount / $messageLimit',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF633B48),
                      ),
                    ),
                  ),
                ],
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
