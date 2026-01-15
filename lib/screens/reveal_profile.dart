import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'chat_screen.dart';
import 'match_screen.dart';

const img2 = "https://www.figma.com/api/mcp/asset/7d708ba7-dd6b-4bbc-830d-38e07589c493";
const img = "https://www.figma.com/api/mcp/asset/0ecef383-d5db-4e43-852b-290f7ef96770";
const img1 = "https://www.figma.com/api/mcp/asset/df46312f-463c-439a-8325-968e3d3d3e25";

class RevealProfileScreen extends StatelessWidget {
  final String userId;

  const RevealProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final profile = StorageService.getProfile(userId);
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Profile not found')));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF3131), Color(0xFFBD5656), Color(0xFFDA3838), Color(0xFFFF0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.20673, 0.74519, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 71),
            child: Container(
              height: 414,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3131), Color(0xFFBD5656), Color(0xFFDA3838), Color(0xFFFF0000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.20673, 0.74519, 1.0],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 414,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCAC4D0)),
                ),
                child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(img),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (profile['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4F378A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1D1B20),
                                    ),
                                  ),
                                  Text(
                                    '${profile['location'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF49454F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {}, // Placeholder for menu
                              icon: Image.network(
                                img1,
                                width: 24,
                                height: 24,
                                color: const Color(0xFF49454F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Media placeholder
                      Container(
                        height: 188,
                        child: Image.network(
                          img2,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.luminosity,
                          color: const Color(0xFFECE6F0),
                        ),
                      ),
                      // Text content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1D1B20),
                                ),
                              ),
                              const Text(
                                'Subtitle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF49454F),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                profile['bio'] ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF49454F),
                                ),
                              ),
                              const Spacer(),
                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              personName: profile['name'] ?? 'Unknown',
                                              chatId: userId,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFB7CD),
                                        foregroundColor: const Color(0xFF633B48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      child: const Text('Back to Chat'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => const MatchScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFF3131), Color(0xFFFF0000)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: const Center(
                                          child: Text('To Matches'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
