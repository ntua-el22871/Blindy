import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'match_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfileCreationScreen extends StatefulWidget {
  final String username;

  const ProfileCreationScreen({
    super.key,
    required this.username,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  // Form data
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  String? _selectedGender;
  String? _selectedAttraction;
  final List<String> _selectedInterests = [];
  final List<String> _photos = [];
  bool _isSaving = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _attractionOptions = ['Male', 'Female', 'Other'];
  final List<String> _interestOptions = [
    'Movies', 'Theater', 'Pets', 'Art', 'Sports', 'Hiking', 'Opera', 'Gaming',
    'Gym', 'Computers', 'Cooking', 'Books', 'Music', 'Series', 'Social'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Save profile to storage
    await StorageService.updateProfile(widget.username, {
      'id': widget.username,
      'name': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': _selectedGender,
      'attraction': _selectedAttraction ?? 'Not specified',
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'interests': _selectedInterests,
      'photos': _photos,
      'profileCompleted': true,
    });

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile created successfully!')),
      );
      
      // Navigate to match screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MatchScreen()),
      );
    }
  }

  void _addPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _photos.add(base64String);
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  'PROFILE CREATION',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name field
                _buildLabel('Name (or Nickname):'),
                _buildTextField(_nameController, 'Type Here'),
                const SizedBox(height: 20),

                // Gender field
                _buildLabel('Gender:'),
                _buildChipSelection(_genderOptions, _selectedGender, (value) {
                  setState(() => _selectedGender = value);
                }),
                const SizedBox(height: 20),

                // Attraction field
                _buildLabel('What gender are you attracted to:'),
                _buildChipSelection(_attractionOptions, _selectedAttraction, (value) {
                  setState(() => _selectedAttraction = value);
                }),
                const SizedBox(height: 20),

                // Age field
                _buildLabel('Age:'),
                _buildTextField(_ageController, 'Enter your age', keyboardType: TextInputType.number),
                const SizedBox(height: 20),

                // Location field
                _buildLabel('Location:'),
                _buildTextField(_locationController, 'Enter your location'),
                const SizedBox(height: 20),

                // Bio field
                _buildLabel('About you:'),
                _buildTextField(_bioController, 'Tell us about yourself', maxLines: 3),
                const SizedBox(height: 20),

                // Photos field
                _buildLabel('Add Photos:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._photos.map((photo) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.memory(
                            base64Decode(photo),
                            fit: BoxFit.cover,
                          ),
                        )),
                    GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Interests field
                _buildLabel('Select interests:'),
                _buildMultiSelectChips(),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3131)),
                            ),
                          )
                        : const Text(
                            'SAVE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF3131),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB7CD)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildChipSelection(
    List<String> options,
    String? selected,
    Function(String) onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? const Color(0xFF633B48) : const Color(0xFF633B48),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: (value) => onChanged(option),
          backgroundColor: isSelected ? const Color(0xFFFFB7CD) : Colors.white.withOpacity(0.1),
          selectedColor: const Color(0xFFFFB7CD),
          showCheckmark: false,
          side: BorderSide(
            color: isSelected ? const Color(0xFFFFB7CD) : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _interestOptions.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return FilterChip(
          label: Text(
            interest,
            style: TextStyle(
              color: isSelected ? const Color(0xFF633B48) : const Color(0xFF633B48),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: (value) {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(interest);
              } else {
                _selectedInterests.add(interest);
              }
            });
          },
          backgroundColor: isSelected ? const Color(0xFFFFB7CD) : Colors.white.withOpacity(0.1),
          selectedColor: const Color(0xFFFFB7CD),
          showCheckmark: false,
          side: BorderSide(
            color: isSelected ? const Color(0xFFFFB7CD) : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        );
      }).toList(),
    );
  }
}
