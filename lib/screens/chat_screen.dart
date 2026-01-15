import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'reveal_profile.dart';

class ChatScreen extends StatefulWidget {
  final String personName;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.personName,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _messages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messages = StorageService.getChatMessages(widget.chatId);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      StorageService.sendMessage(widget.chatId, _controller.text);
      _controller.clear();
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool revealEnabled = StorageService.isRevealEnabled(widget.chatId);
    bool hasRequested = StorageService.hasRequestedReveal(widget.chatId);

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
              // Header with back button and name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB7CD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF633B48),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.personName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Reveal button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: revealEnabled
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RevealProfileScreen(userId: widget.chatId),
                              ),
                            );
                          }
                        : hasRequested
                            ? null
                            : () async {
                                await StorageService.requestReveal(widget.chatId);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reveal requested. Waiting for the other user.')),
                                );
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: revealEnabled ? const Color(0xFFFFB7CD) : hasRequested ? Colors.grey : const Color(0xFFFFB7CD),
                      foregroundColor: revealEnabled ? const Color(0xFF633B48) : hasRequested ? Colors.white : const Color(0xFF633B48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      revealEnabled ? 'Reveal Profile' : hasRequested ? 'Waiting for other user...' : 'Request Reveal',
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isSentByMe = msg['sender'] == StorageService.getLoggedInUser();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isSentByMe
                                ? const Color(0xFFFFB7CD)
                                : const Color(0xFF633B48),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isSentByMe
                                      ? const Color(0xFF633B48)
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['timestamp'] != null
                                    ? _formatTime(DateTime.parse(msg['timestamp']))
                                    : '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSentByMe
                                      ? Color(0xFF633B48).withOpacity(0.6)
                                      : Colors.white70,
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
              // Input field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white10,
                  border: Border(
                    top: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Start Chatting...',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color(0xFFFFB7CD)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: const Color(0xFFFFB7CD),
                      child: const Icon(
                        Icons.send,
                        color: Color(0xFF633B48),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (msgDate == yesterday) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}