import 'package:hive/hive.dart';

class StorageService {
  // Get Hive boxes
  static Box get _usersBox => Hive.box('appData');
  static Box get _profilesBox => Hive.box('appData');
  static Box get _likesBox => Hive.box('appData');
  static Box get _messagesBox => Hive.box('appData');

  /// ==================== USER MANAGEMENT ====================

  /// Register a new user
  static Future<bool> registerUser(String username, String password) async {
    try {
      // Check if user already exists
      final users = _usersBox.get('users', defaultValue: {}) as Map;
      
      if (users.containsKey(username)) {
        return false; // User already exists
      }

      // Add new user
      users[username] = {
        'username': username,
        'password': password, // In production, hash this!
        'createdAt': DateTime.now().toString(),
      };

      await _usersBox.put('users', users);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// Login user
  static Future<bool> loginUser(String username, String password) async {
    try {
      final users = _usersBox.get('users', defaultValue: {}) as Map;
      
      if (!users.containsKey(username)) {
        return false; // User doesn't exist
      }

      final user = users[username] as Map;
      if (user['password'] == password) {
        return true; // Login successful
      }
      return false; // Wrong password
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  /// Save currently logged in user
  static Future<void> saveLoggedInUser(String username) async {
    try {
      await _usersBox.put('loggedInUser', username);
    } catch (e) {
      print('Error saving logged in user: $e');
    }
  }

  /// Get currently logged in user
  static String? getLoggedInUser() {
    try {
      return _usersBox.get('loggedInUser') as String?;
    } catch (e) {
      print('Error getting logged in user: $e');
      return null;
    }
  }

  /// Logout user
  static Future<void> logoutUser() async {
    try {
      await _usersBox.delete('loggedInUser');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  /// ==================== DUMMY PROFILES ====================

  /// Insert dummy dating profiles on first launch
  static Future<void> insertDummyProfiles() async {
    try {
      // Check if profiles already exist
      final profiles = _profilesBox.get('profiles', defaultValue: {}) as Map;
      
      if (profiles.isNotEmpty) {
        return; // Profiles already exist
      }

      // Add dummy profiles
      final dummyProfiles = {
        '1': {
          'id': '1',
          'name': 'Emma',
          'age': 24,
          'gender': 'Female',
          'location': 'Athens',
          'bio': 'Love hiking and coffee. Let\'s explore the city together!',
          'image': 'assets/images/emma.jpg',
        },
        '2': {
          'id': '2',
          'name': 'Sofia',
          'age': 23,
          'gender': 'Female',
          'location': 'Glyfada',
          'bio': 'Book lover, yoga enthusiast, and always up for adventures.',
          'image': 'assets/images/sofia.jpg',
        },
        '3': {
          'id': '3',
          'name': 'Maria',
          'age': 25,
          'gender': 'Female',
          'location': 'Kolonaki',
          'bio': 'Artist by day, night owl by night. Let\'s have a great conversation!',
          'image': 'assets/images/maria.jpg',
        },
        '4': {
          'id': '4',
          'name': 'Alex',
          'age': 26,
          'gender': 'Female',
          'location': 'Psyrri',
          'bio': 'Foodie, traveler, and dog lover. Always smiling!',
          'image': 'assets/images/alex.jpg',
        },
        '5': {
          'id': '5',
          'name': 'Nina',
          'age': 22,
          'gender': 'Female',
          'location': 'Exarcheia',
          'bio': 'Music enthusiast with a passion for photography.',
          'image': 'assets/images/nina.jpg',
        },
      };

      await _profilesBox.put('profiles', dummyProfiles);
    } catch (e) {
      print('Error inserting dummy profiles: $e');
    }
  }

  /// Get all profiles
  static List<Map> getAllProfiles() {
    try {
      final profiles = _profilesBox.get('profiles', defaultValue: {}) as Map;
      return profiles.values.cast<Map>().toList();
    } catch (e) {
      print('Error getting profiles: $e');
      return [];
    }
  }

  /// Get a specific profile by ID
  static Map? getProfile(String profileId) {
    try {
      final profiles = _profilesBox.get('profiles', defaultValue: {}) as Map;
      return profiles[profileId] as Map?;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// ==================== LIKE & MATCH SYSTEM ====================

  /// Like a profile
  static Future<void> likeProfile(String currentUser, String targetProfileId) async {
    try {
      final likes = _likesBox.get('likes', defaultValue: {}) as Map;

      if (!likes.containsKey(currentUser)) {
        likes[currentUser] = [];
      }

      final userLikes = likes[currentUser] as List;
      if (!userLikes.contains(targetProfileId)) {
        userLikes.add(targetProfileId);
        likes[currentUser] = userLikes;
        await _likesBox.put('likes', likes);
      }
    } catch (e) {
      print('Error liking profile: $e');
    }
  }

  /// Unlike a profile
  static Future<void> unlikeProfile(String currentUser, String targetProfileId) async {
    try {
      final likes = _likesBox.get('likes', defaultValue: {}) as Map;

      if (likes.containsKey(currentUser)) {
        final userLikes = likes[currentUser] as List;
        userLikes.removeWhere((id) => id == targetProfileId);
        likes[currentUser] = userLikes;
        await _likesBox.put('likes', likes);
      }
    } catch (e) {
      print('Error unliking profile: $e');
    }
  }

  /// Check if two users matched
  static bool checkMatch(String currentUser, String targetProfileId) {
    try {
      final likes = _likesBox.get('likes', defaultValue: {}) as Map;

      // Check if current user liked target profile
      bool currentUserLiked = false;
      if (likes.containsKey(currentUser)) {
        final userLikes = likes[currentUser] as List;
        currentUserLiked = userLikes.contains(targetProfileId);
      }

      // Check if target profile liked current user
      bool targetUserLiked = false;
      if (likes.containsKey(targetProfileId)) {
        final userLikes = likes[targetProfileId] as List;
        targetUserLiked = userLikes.contains(currentUser);
      }

      // Match occurs when both liked each other
      return currentUserLiked && targetUserLiked;
    } catch (e) {
      print('Error checking match: $e');
      return false;
    }
  }

  /// Get all matches for a user
  static List<Map> getMatches(String currentUser) {
    try {
      final likes = _likesBox.get('likes', defaultValue: {}) as Map;
      final profiles = _profilesBox.get('profiles', defaultValue: {}) as Map;
      final matches = <Map>[];

      // Get users that current user liked
      if (likes.containsKey(currentUser)) {
        final userLikes = likes[currentUser] as List;

        for (String targetProfileId in userLikes) {
          // Check if they also liked current user
          if (likes.containsKey(targetProfileId)) {
            final targetLikes = likes[targetProfileId] as List;
            if (targetLikes.contains(currentUser)) {
              // This is a match!
              if (profiles.containsKey(targetProfileId)) {
                matches.add(profiles[targetProfileId] as Map);
              }
            }
          }
        }
      }

      return matches;
    } catch (e) {
      print('Error getting matches: $e');
      return [];
    }
  }

  /// Get all users that current user liked
  static List<String> getLikedProfiles(String currentUser) {
    try {
      final likes = _likesBox.get('likes', defaultValue: {}) as Map;

      if (likes.containsKey(currentUser)) {
        return List<String>.from(likes[currentUser] as List);
      }
      return [];
    } catch (e) {
      print('Error getting liked profiles: $e');
      return [];
    }
  }

  /// ==================== CHAT SYSTEM ====================

  /// Send a message between two users
  static Future<void> sendMessage(
    String fromUser,
    String toUser,
    String text,
  ) async {
    try {
      final messages = _messagesBox.get('messages', defaultValue: {}) as Map;

      // Create a conversation key (sort usernames to ensure consistency)
      final users = [fromUser, toUser]..sort();
      final conversationKey = '${users[0]}_${users[1]}';

      if (!messages.containsKey(conversationKey)) {
        messages[conversationKey] = [];
      }

      final conversation = messages[conversationKey] as List;
      
      conversation.add({
        'from': fromUser,
        'to': toUser,
        'text': text,
        'timestamp': DateTime.now().toString(),
      });

      messages[conversationKey] = conversation;
      await _messagesBox.put('messages', messages);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  /// Get all messages between two users
  static List<Map<String, dynamic>> getMessagesBetween(String userA, String userB) {
    try {
      final messages = _messagesBox.get('messages', defaultValue: {}) as Map;

      // Create a conversation key (sort usernames to ensure consistency)
      final users = [userA, userB]..sort();
      final conversationKey = '${users[0]}_${users[1]}';

      if (messages.containsKey(conversationKey)) {
        final messageList = messages[conversationKey] as List;
        return messageList
            .map((msg) => Map<String, dynamic>.from(msg as Map))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  /// Get all conversations for a user
  static List<String> getConversations(String username) {
    try {
      final messages = _messagesBox.get('messages', defaultValue: {}) as Map;
      final conversations = <String>[];

      for (String key in messages.keys) {
        if (key.contains(username)) {
          conversations.add(key);
        }
      }

      return conversations;
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  /// ==================== UTILITY ====================

  /// Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    try {
      await _usersBox.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
