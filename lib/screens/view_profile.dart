import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfile {
  String name;
  String age;
  String gender;
  String attractedTo;
  String bio;
  List<String> interests;
  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.attractedTo,
    required this.bio,
    required this.interests,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'attractedTo': attractedTo,
    'bio': bio,
    'interests': interests,
  };
  static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    age: json['age'] ?? '',
    gender: json['gender'] ?? '',
    attractedTo: json['attractedTo'] ?? '',
    bio: json['bio'] ?? '',
    interests: List<String>.from(json['interests'] ?? []),
  );
}

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _gender = 'Female';
  String _attractedTo = 'Male';
  List<String> _interests = [];

  final List<String> _genderOptions = ['Female', 'Male', 'Other'];
  final List<String> _attractedToOptions = ['Female', 'Male', 'Other'];
  final List<String> _allInterests = [
    'Books', 'Hiking', 'Coffee', 'Art', 'Movies', 'Food', 'Gaming', 'Music', 'Pets', 'Travel', 'Gym', 'Social'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_profile');
    if (jsonStr != null) {
      final data = json.decode(jsonStr);
      final profile = UserProfile.fromJson(data);
      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age;
        _gender = profile.gender;
        _attractedTo = profile.attractedTo;
        _bioController.text = profile.bio;
        _interests = profile.interests;
      });
    } else {
      // Defaults
      setState(() {
        _nameController.text = '';
        _ageController.text = '';
        _gender = 'Female';
        _attractedTo = 'Male';
        _bioController.text = '';
        _interests = [];
      });
    }
  }

  Future<void> _saveProfile() async {
    final profile = UserProfile(
      name: _nameController.text,
      age: _ageController.text,
      gender: _gender,
      attractedTo: _attractedTo,
      bio: _bioController.text,
      interests: _interests,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
    }
  }

  void _editInterests() async {
    final temp = List<String>.from(_interests);
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF633B48),
              title: const Text('Edit Interests', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 300,
                child: Wrap(
                  spacing: 8,
                  children: _allInterests.map((interest) {
                    final selected = temp.contains(interest);
                    return FilterChip(
                      label: Text(interest, style: TextStyle(color: selected ? Color(0xFF633B48) : Colors.white)),
                      selected: selected,
                      selectedColor: const Color(0xFFFFB7CD),
                      backgroundColor: const Color(0xFF633B48),
                      onSelected: (val) {
                        setStateDialog(() {
                          if (val && temp.length < 6) {
                            temp.add(interest);
                          } else if (!val) {
                            temp.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, temp),
                  child: const Text('Save', style: TextStyle(color: Color(0xFFFFB7CD))),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null) {
      setState(() {
        _interests = selected;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_genderOptions.contains(_gender)) {
      _gender = _genderOptions.first;
    }
    if (!_attractedToOptions.contains(_attractedTo)) {
      _attractedTo = _attractedToOptions.first;
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
            // --- ΤΟ ΚΟΥΜΠΙ PREV ---
            // Χρησιμοποιούμε pop για να γυρίσουμε πίσω
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
                    // ΕΠΙΣΤΡΟΦΗ ΧΩΡΙΣ RESET
                    Navigator.of(context).pop();
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
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Profile',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 40,
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
                      _editableField('Name', _nameController),
                      const SizedBox(height: 16),
                      _editableField('Age', _ageController, isNumber: true),
                      const SizedBox(height: 16),
                      _dropdownField('Gender', _gender, _genderOptions, (val) => setState(() => _gender = val)),
                      const SizedBox(height: 16),
                      _dropdownField('Attracted To', _attractedTo, _attractedToOptions, (val) => setState(() => _attractedTo = val)),
                      const SizedBox(height: 16),
                      _editableField('Bio', _bioController, maxLines: 3),
                      const SizedBox(height: 16),
                      Text('Interests', style: _labelStyle),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          ..._interests.map((i) => Chip(
                                label: Text(i, style: const TextStyle(color: Color(0xFF633B48))),
                                backgroundColor: const Color(0xFFFFB7CD),
                              )),
                          ActionChip(
                            label: const Text('Edit', style: TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFFBD5656),
                            onPressed: _editInterests,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB7CD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveProfile,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Color(0xFF633B48),
                              ),
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

  Widget _editableField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFB7CD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB7CD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF633B48)),
            dropdownColor: const Color(0xFFFFB7CD),
            underline: const SizedBox(),
            style: const TextStyle(color: Color(0xFF633B48), fontSize: 18),
            onChanged: (val) => onChanged(val!),
            items: options.map((opt) => DropdownMenuItem(
              value: opt,
              child: Text(opt),
            )).toList(),
          ),
        ),
      ],
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: Colors.white70,
  );
}