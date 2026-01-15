import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class RevealProfileScreen extends StatefulWidget {
  final String userId;

  const RevealProfileScreen({super.key, required this.userId});

  @override
  State<RevealProfileScreen> createState() => _RevealProfileScreenState();
}

class _RevealProfileScreenState extends State<RevealProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    try {
      final userProfiles = StorageService.appData.get('userProfiles') ?? {};
      final profile = userProfiles[widget.userId];
      setState(() {
        _profile = profile != null ? Map<String, dynamic>.from(profile) : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _profile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
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
              // Back button
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
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
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF633B48).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Profile not available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            // Back button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
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
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_profile!['name'] ?? 'Unknown'}\'s Profile',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 160, bottom: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF633B48).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoField('Name', _profile!['name'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _infoField('Age', _profile!['age'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _infoField('Gender', _profile!['gender'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _infoField('Attracted To', _profile!['attraction'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _infoField('Bio', _profile!['bio'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _infoField('Location', _profile!['location'] ?? 'Not provided'),
                      const SizedBox(height: 16),
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB7CD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No photos uploaded yet',
                            style: TextStyle(
                              color: Color(0xFF633B48),
                              fontSize: 18,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB7CD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF633B48),
              fontSize: 18,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }
}