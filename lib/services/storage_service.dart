import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Box get _box => Hive.box('appData');
  
  // Expose for direct access to appData
  static Box get appData => _box;

  /// ΚΑΘΑΡΙΣΜΟΣ ΒΑΣΗΣ (Για debugging)
  static Future<void> clearAll() async {
    await _box.clear();
    print("--- DATABASE CLEARED ---");
  }

  // --- 1. USER AUTHENTICATION ---

  /// Εγγραφή χρήστη & δημιουργία προφίλ
  static Future<bool> registerUser(String username, String password) async {
    try {
      print("Attempting to register: $username");
      final users = Map<String, dynamic>.from(_box.get('users', defaultValue: {}));
      
      if (users.containsKey(username)) {
        return false; 
      }

      // Αποθήκευση User
      users[username] = {
        'username': username,
        'password': password,
        'createdAt': DateTime.now().toString(),
      };
      await _box.put('users', users);

      // Αποθήκευση Προφίλ
      final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
      profiles[username] = {
        'id': username,
        'name': username, 
        'age': '25',
        'gender': 'Unknown',
        'location': 'Athens',
        'bio': 'New user on Blindy!',
        'interests': ['Coffee', 'Music'],
      };
      await _box.put('profiles', profiles);

      // Dummy accounts like all new users
      final likes = Map<String, dynamic>.from(_box.get('likes', defaultValue: {}));
      if (profiles.containsKey('alice')) {
        if (!likes.containsKey('alice')) likes['alice'] = [];
        final aliceLikes = List.from(likes['alice']);
        if (!aliceLikes.contains(username)) {
          aliceLikes.add(username);
          likes['alice'] = aliceLikes;
        }
      }
      if (profiles.containsKey('bob')) {
        if (!likes.containsKey('bob')) likes['bob'] = [];
        final bobLikes = List.from(likes['bob']);
        if (!bobLikes.contains(username)) {
          bobLikes.add(username);
          likes['bob'] = bobLikes;
        }
      }
      await _box.put('likes', likes);
      
      return true;
    } catch (e) {
      print('Error registering: $e');
      return false;
    }
  }

  /// Login
  static Future<bool> loginUser(String username, String password) async {
    final users = Map<String, dynamic>.from(_box.get('users', defaultValue: {}));
    if (!users.containsKey(username)) return false;

    final user = users[username] as Map;
    if (user['password'] == password) {
      // Σημείωση: Το saveLoggedInUser καλείται και από το credentials.dart,
      // αλλά το κάνουμε και εδώ για σιγουριά.
      await _box.put('loggedInUser', username);
      print("User $username logged in.");
      return true;
    }
    return false;
  }

  /// Αποθήκευση συνδεδεμένου χρήστη (Ζητείται από το credentials.dart)
  static Future<void> saveLoggedInUser(String username) async {
    await _box.put('loggedInUser', username);
  }

  static String? getLoggedInUser() {
    return _box.get('loggedInUser');
  }

  static Future<void> logoutUser() async {
    await _box.delete('loggedInUser');
  }

  // --- 2. DATA & PROFILES ---

  /// Εισαγωγή ψεύτικων προφίλ (Ζητείται από το credentials.dart)
  static Future<void> insertDummyProfiles() async {
    final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
    
    // Αν δεν υπάρχουν προφίλ, φτιάξε μερικά για να μην είναι άδειο
    if (profiles.isEmpty) {
      print("Inserting dummy profiles...");
      profiles['maria'] = {
        'id': 'maria', 'name': 'Maria', 'age': '24', 'location': 'Athens',
        'bio': 'Coffee lover ☕', 'interests': ['Coffee', 'Art']
      };
      profiles['giannis'] = {
        'id': 'giannis', 'name': 'Giannis', 'age': '26', 'location': 'Thessaloniki',
        'bio': 'Travel addict ✈️', 'interests': ['Travel', 'Gym']
      };
      await _box.put('profiles', profiles);
    }
  }

  /// Λήψη προφίλ για Swipe (Εξαιρώντας τον εαυτό μας και τα likes)
  static List<Map<String, dynamic>> getProfilesToSwipe() {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return [];

    final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
    final likes = Map<String, dynamic>.from(_box.get('likes', defaultValue: {}));

    List myLikes = [];
    if (likes.containsKey(currentUser)) {
      myLikes = List.from(likes[currentUser]);
    }

    List<Map<String, dynamic>> result = [];
    profiles.forEach((key, value) {
      if (key != currentUser && !myLikes.contains(key)) {
        result.add(Map<String, dynamic>.from(value as Map));
      }
    });
    
    return result;
  }

  /// Update profile
  static Future<void> updateProfile(String userId, Map<String, dynamic> profileData) async {
    // Update both structures for backward compatibility
    final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
    profiles[userId] = profileData;
    await _box.put('profiles', profiles);
    
    // Also update userProfiles for new structure
    final userProfiles = Map<String, dynamic>.from(_box.get('userProfiles', defaultValue: {}));
    userProfiles[userId] = profileData;
    await _box.put('userProfiles', userProfiles);
  }

  // --- 3. MATCHING SYSTEM ---

  static Future<void> likeProfile(String targetId) async {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return;

    final likes = Map<String, dynamic>.from(_box.get('likes', defaultValue: {}));
    if (!likes.containsKey(currentUser)) likes[currentUser] = [];

    final userLikes = List.from(likes[currentUser]);
    if (!userLikes.contains(targetId)) {
      userLikes.add(targetId);
      likes[currentUser] = userLikes;
      await _box.put('likes', likes);
      print("$currentUser LIKED $targetId");

      // Special handling for dummy accounts: auto-enable reveal on match
      if (checkMatch(targetId) && (targetId == 'alice' || targetId == 'bob')) {
        final conversationKey = _getChatKey(currentUser, targetId);
        final reveals = Map<String, dynamic>.from(_box.get('reveals', defaultValue: {}));
        reveals[conversationKey] = [currentUser, targetId];
        await _box.put('reveals', reveals);
        print("Auto-enabled reveal for $currentUser and $targetId");

        // Send auto hello message from the dummy account
        await sendMessage(currentUser, "Hello! I'm ${targetId == 'alice' ? 'Alice' : 'Bob'}! Nice to match with you! 😊", sender: targetId);
        print("Auto-sent hello message from $targetId to $currentUser");
      }
    }
  }

  static bool checkMatch(String targetId) {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return false;

    final likes = Map<String, dynamic>.from(_box.get('likes', defaultValue: {}));
    
    bool iLiked = (likes[currentUser] as List? ?? []).contains(targetId);
    bool theyLiked = (likes[targetId] as List? ?? []).contains(currentUser);

    return iLiked && theyLiked;
  }

  static Future<List<Map<String, String>>> getMatchesForInbox() async {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return [];

    final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
    final matches = <Map<String, String>>[];

    profiles.forEach((key, value) {
      if (key != currentUser && checkMatch(key)) {
        matches.add({
          'name': value['name'],
          'lastMessage': 'It\'s a match!',
          'chatId': key,
          'location': value['location'] ?? '',
        });
      }
    });
    return matches;
  }

  // --- 4. CHAT SYSTEM ---

  /// Get chat messages between two users
  static List<Map<String, dynamic>> getChatMessages(String chatId) {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return [];

    final chats = Map<String, dynamic>.from(_box.get('chats', defaultValue: {}));
    final conversationKey = _getChatKey(currentUser, chatId);
    
    final messages = List<Map<String, dynamic>>.from(
      (chats[conversationKey] ?? []).map((m) => Map<String, dynamic>.from(m as Map))
    );
    
    return messages;
  }

  /// Send a message in chat
  static Future<void> sendMessage(String chatId, String message, {String? sender}) async {
    sender ??= getLoggedInUser();
    if (sender == null) return;

    final chats = Map<String, dynamic>.from(_box.get('chats', defaultValue: {}));
    final conversationKey = _getChatKey(sender, chatId);
    
    final messageData = {
      'sender': sender,
      'text': message,
      'timestamp': DateTime.now().toString(),
    };

    final messages = List<Map<String, dynamic>>.from(
      (chats[conversationKey] ?? []).map((m) => Map<String, dynamic>.from(m as Map))
    );
    messages.add(messageData);
    chats[conversationKey] = messages;
    
    await _box.put('chats', chats);
  }

  /// Generate consistent chat key between two users (order doesn't matter)
  static String _getChatKey(String user1, String user2) {
    final users = [user1, user2]..sort();
    return '${users[0]}_${users[1]}';
  }

  // --- 5. REVEAL SYSTEM ---

  static Future<void> requestReveal(String chatId) async {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return;

    final conversationKey = _getChatKey(currentUser, chatId);
    final reveals = Map<String, dynamic>.from(_box.get('reveals', defaultValue: {}));
    
    if (!reveals.containsKey(conversationKey)) reveals[conversationKey] = [];
    final requests = List.from(reveals[conversationKey]);
    
    if (!requests.contains(currentUser)) {
      requests.add(currentUser);
      reveals[conversationKey] = requests;
      await _box.put('reveals', reveals);
    }
  }

  static bool isRevealEnabled(String chatId) {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return false;

    final conversationKey = _getChatKey(currentUser, chatId);
    final reveals = Map<String, dynamic>.from(_box.get('reveals', defaultValue: {}));
    final requests = List.from(reveals[conversationKey] ?? []);
    
    return requests.contains(currentUser) && requests.contains(chatId);
  }

  static bool hasRequestedReveal(String chatId) {
    String? currentUser = getLoggedInUser();
    if (currentUser == null) return false;

    final conversationKey = _getChatKey(currentUser, chatId);
    final reveals = Map<String, dynamic>.from(_box.get('reveals', defaultValue: {}));
    final requests = List.from(reveals[conversationKey] ?? []);
    
    return requests.contains(currentUser);
  }

  static Map<String, dynamic>? getProfile(String userId) {
    final profiles = Map<String, dynamic>.from(_box.get('profiles', defaultValue: {}));
    final profile = profiles[userId];
    return profile != null ? Map<String, dynamic>.from(profile as Map) : null;
  }
}