# Blindy - Matching & Chat Feature Guide

## Overview
Your app now has a fully functional matching and chat system! Two users can match with each other and have persistent conversations.

## Quick Start - Testing the Feature

### Method 1: Auto-Setup (Recommended)
1. Launch the app
2. **Tap the green "+" button** (Add Person icon) in the bottom-right
3. This creates two test users: **alice** and **bob** who already match
4. Login as: `alice` / `password123`
5. You'll see Bob in your matches
6. Click the chat bubble icon → "Go to Matches" → tap Bob's profile to chat

### Method 2: Manual Setup
1. Create two accounts manually:
   - Account 1: username: `alice`, password: `password123`
   - Account 2: username: `bob`, password: `password123`
2. Login as alice, swipe right on every profile to like bob
3. Login as bob, swipe right on alice to match
4. Now they can chat!

## How It Works

### User Registration & Login
- Users are stored in Hive database with credentials
- Each user has a profile with: name, age, location, bio, interests
- Current logged-in user is tracked

### Matching System
- **Like**: When a user likes another profile, it's recorded
- **Mutual Like = Match**: When both users like each other, it's a match
- Matches appear in the Inbox

### Chat System (NEW!)
- Messages are **persistent** (stored in Hive database)
- Each conversation has a unique key based on the two users' IDs
- Messages include: sender, text, and timestamp
- Messages appear in chronological order with visual distinction (sent vs received)

## Key Files Modified

### 1. **lib/services/storage_service.dart**
Added chat functionality:
```dart
// Get all messages in a conversation
getChatMessages(chatId) → List<Map>

// Send a message
sendMessage(chatId, message) → Future<void>

// Get profile data
updateProfile(userId, profileData) → Future<void>
```

### 2. **lib/screens/chat_screen.dart**
Completely revamped:
- Loads messages from database on init
- Displays messages with timestamps
- Styled message bubbles (different colors for sent/received)
- Send button saves messages persistently

### 3. **lib/screens/login_screen.dart**
Added test user setup:
- Green "+" button creates alice & bob (already matched)
- Trash button clears entire database
- Helpful tips for testing

## Features

✅ **User Authentication** - Register and login  
✅ **Profile Creation** - Set name, age, location, bio, interests  
✅ **Swiping** - Swipe profiles left (pass) or right (like)  
✅ **Matching** - Mutual likes = match  
✅ **Chat** - Real-time messaging with persistent storage  
✅ **Inbox** - View all matches  
✅ **Message History** - All messages are saved  

## Technical Details

### Database Structure (Hive)
```
appData Box:
├── users → {username: {username, password, createdAt}}
├── profiles → {userId: {id, name, age, gender, location, bio, interests}}
├── likes → {userId: [likedUserIds...]}
├── chats → {user1_user2: [{sender, text, timestamp}...]}
└── loggedInUser → current_username
```

### Message Key Generation
Messages between two users are stored with a consistent key:
- Alphabetically sort usernames: [alice, bob] → "alice_bob"
- Regardless of who initiates the chat, it's the same conversation

## Testing Scenarios

### Scenario 1: Alice likes Bob, Bob hasn't liked back
1. Login as alice
2. See Bob in profiles, swipe right ❤️
3. Logout, login as bob
4. Alice won't appear in matches (no mutual like yet)

### Scenario 2: Mutual Match (Both like each other)
1. Alice swipes right on Bob
2. Bob swipes right on Alice
3. Both see each other in Matches
4. Both can chat

### Scenario 3: Start a conversation
1. Go to Matches
2. Tap a matched user
3. Type a message and send
4. Message appears immediately and is saved
5. Switch to the other user's account
6. The message history is visible

## Troubleshooting

**Messages not appearing?**
- Ensure both users have matched (check Matches tab)
- Clear database (trash icon) and recreate test users

**Can't find matches?**
- Use the green button to auto-create test users
- Manually like profiles with the right arrow

**Database stuck?**
- Tap the trash icon to clear all data
- Start fresh

## Future Enhancements

Consider adding:
- Photo/image upload for profiles
- User notifications when there's a new match
- Message delivery status (read/unread)
- Message search
- Delete message functionality
- User blocking
- Real-time chat using Firebase

## Notes for Developers

The chat system uses:
- **Hive** for local persistent storage
- **Flutter setState** for UI updates
- Message timestamps in ISO format for sorting
- Sorted usernames for chat key consistency

All conversations are stored locally and would need cloud sync for multi-device support.
