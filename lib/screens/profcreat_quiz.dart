import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'match_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
	const ProfileCreationScreen({super.key});

	@override
	State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
	final TextEditingController nameController = TextEditingController();
	final TextEditingController ageController = TextEditingController();
	final TextEditingController aboutController = TextEditingController();

	String selectedGender = 'FEMALE';
	String attractedTo = 'MALE';
	List<String> interests = [
		'Movies', 'Theater', 'Pets', 'Art', 'Sports', 'Hiking', 'Opera', 'Gaming', 'Gym',
		'Computers', 'Cooking', 'Books', 'Music', 'Series', 'Social'
	];
	Set<String> selectedInterests = {'Movies', 'Gaming', 'Books'};

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
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Center(
								child: Text(
									'PROFILE CREATION',
									style: TextStyle(
										fontFamily: 'Roboto',
										fontWeight: FontWeight.w400,
										fontSize: 36,
										color: Colors.white,
										letterSpacing: 0,
									),
								),
							),
							const SizedBox(height: 30),
							const Text(
								'Name (or Nickname):',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							TextField(
								controller: nameController,
								style: const TextStyle(color: Colors.white),
								decoration: InputDecoration(
									filled: true,
									fillColor: Colors.white.withOpacity(0.1),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
									),
									hintText: 'Type Here',
									hintStyle: const TextStyle(color: Colors.white70),
								),
							),
							const SizedBox(height: 20),
							const Text(
								'Age',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							TextField(
								controller: ageController,
								keyboardType: TextInputType.number,
								style: const TextStyle(color: Colors.white),
								decoration: InputDecoration(
									filled: true,
									fillColor: Colors.white.withOpacity(0.1),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
									),
									hintText: 'Input',
									hintStyle: const TextStyle(color: Colors.white70),
								),
							),
							const SizedBox(height: 20),
							const Text(
								'Gender:',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							Row(
								children: [
									_FilterChip(
										label: 'FEMALE',
										selected: selectedGender == 'FEMALE',
										onTap: () => setState(() => selectedGender = 'FEMALE'),
										distinguish: true,
									),
									const SizedBox(width: 8),
									_FilterChip(
										label: 'MALE',
										selected: selectedGender == 'MALE',
										onTap: () => setState(() => selectedGender = 'MALE'),
										distinguish: true,
									),
									const SizedBox(width: 8),
									_FilterChip(
										label: 'OTHER',
										selected: selectedGender == 'OTHER',
										onTap: () => setState(() => selectedGender = 'OTHER'),
										distinguish: true,
									),
								],
							),
							const SizedBox(height: 20),
							const Text(
								'What gender are you attracted to:',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							Row(
								children: [
									_FilterChip(
										label: 'FEMALE',
										selected: attractedTo == 'FEMALE',
										onTap: () => setState(() => attractedTo = 'FEMALE'),
										distinguish: true,
									),
									const SizedBox(width: 8),
									_FilterChip(
										label: 'MALE',
										selected: attractedTo == 'MALE',
										onTap: () => setState(() => attractedTo = 'MALE'),
										distinguish: true,
									),
									const SizedBox(width: 8),
									_FilterChip(
										label: 'OTHER',
										selected: attractedTo == 'OTHER',
										onTap: () => setState(() => attractedTo = 'OTHER'),
										distinguish: true,
									),
								],
							),
							const SizedBox(height: 20),
							const Text(
								'Add your photos here',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							Container(
								width: 185,
								height: 100,
								decoration: BoxDecoration(
									border: Border.all(color: Colors.white, width: 2),
									borderRadius: BorderRadius.circular(12),
									color: Colors.white.withOpacity(0.1),
								),
								child: const Center(
									child: Icon(Icons.add, color: Colors.white, size: 40),
								),
							),
							const SizedBox(height: 20),
							const Text(
								'About you:',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							TextField(
								controller: aboutController,
								maxLines: 3,
								style: const TextStyle(color: Colors.white),
								decoration: InputDecoration(
									filled: true,
									fillColor: Colors.white.withOpacity(0.1),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
									),
									hintText: 'Tell us about yourself',
									hintStyle: const TextStyle(color: Colors.white70),
								),
							),
							const SizedBox(height: 20),
							const Text(
								'Select interests:',
								style: TextStyle(
									fontFamily: 'Roboto',
									fontWeight: FontWeight.w500,
									fontSize: 16,
									color: Colors.white,
									letterSpacing: 0.15,
								),
							),
							const SizedBox(height: 8),
							Wrap(
								spacing: 8,
								runSpacing: 8,
								children: interests.map((interest) => _FilterChip(
									label: interest,
									selected: selectedInterests.contains(interest),
									onTap: () {
										setState(() {
											if (selectedInterests.contains(interest)) {
												selectedInterests.remove(interest);
											} else if (selectedInterests.length < 6) {
												selectedInterests.add(interest);
											}
										});
									},
									disabled: !selectedInterests.contains(interest) && selectedInterests.length >= 6,
									distinguish: true,
								)).toList(),
							),
							const SizedBox(height: 30),
							Center(
								child: SizedBox(
									width: 199,
									height: 48,
									child: ElevatedButton(
										style: ElevatedButton.styleFrom(
											backgroundColor: const Color(0xFFFFB7CD),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(100),
											),
										),
										onPressed: () async {
											// Save profile data to shared_preferences
											final prefs = await SharedPreferences.getInstance();
											final profile = {
												'name': nameController.text,
												'age': ageController.text,
												'gender': selectedGender,
												'attractedTo': attractedTo,
												'bio': aboutController.text,
												'interests': selectedInterests.toList(),
											};
											await prefs.setString('user_profile', json.encode(profile));
											Navigator.of(context).push(
												MaterialPageRoute(
													builder: (context) => const QuizScreen(),
												),
											);
										},
										child: const Text(
											'NEXT',
											style: TextStyle(
												fontFamily: 'Roboto',
												fontWeight: FontWeight.w400,
												fontSize: 24,
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
		);
	}
}

class _FilterChip extends StatelessWidget {
	final String label;
	final bool selected;
	final VoidCallback onTap;
	final bool disabled;
	final bool distinguish;
	const _FilterChip({required this.label, required this.selected, required this.onTap, this.disabled = false, this.distinguish = false, super.key});

	@override
	Widget build(BuildContext context) {
		final Color selectedBg = Colors.white;
		final Color selectedText = Color(0xFF633B48);
		final Color unselectedBg = distinguish ? Color(0xFFFFB7CD) : Colors.white.withOpacity(0.1);
		final Color unselectedText = distinguish ? Color(0xFF633B48) : Colors.white;
		return FilterChip(
			label: Text(label),
			selected: selected,
			onSelected: disabled ? null : (_) => onTap(),
			selectedColor: selectedBg,
			checkmarkColor: selectedText,
			backgroundColor: selected ? selectedBg : unselectedBg,
			labelStyle: TextStyle(color: selected ? selectedText : unselectedText),
			side: BorderSide(color: selected ? selectedText : unselectedText.withOpacity(0.7)),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
			disabledColor: Colors.white.withOpacity(0.05),
		);
	}
}

class QuizScreen extends StatefulWidget {
	const QuizScreen({super.key});

	@override
	State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
	final List<String> questions = [
		'Do you like outdoor activities?',
		'Are you a morning person?',
		'Do you enjoy reading books?',
		'Do you like pets?',
		'Do you enjoy cooking?'
	];
	final Map<int, String> answers = {};
	final List<String> options = ['NO', 'MAYBE', 'YES'];

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
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Center(
								child: Text(
									'ANSWER THESE QUESTIONS',
									style: TextStyle(
										fontFamily: 'Roboto',
										fontWeight: FontWeight.w500,
										fontSize: 20,
										color: Colors.white,
									),
								),
							),
							const SizedBox(height: 30),
							Expanded(
								child: ListView.separated(
									itemCount: questions.length,
									separatorBuilder: (_, __) => const SizedBox(height: 24),
									itemBuilder: (context, idx) {
										return Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													'Question ${idx + 1}:',
													style: const TextStyle(
														fontFamily: 'Roboto',
														fontWeight: FontWeight.w500,
														fontSize: 16,
														color: Colors.white,
													),
												),
												const SizedBox(height: 6),
												Text(
													questions[idx],
													style: const TextStyle(
														fontFamily: 'Roboto',
														fontWeight: FontWeight.normal,
														fontSize: 18,
														color: Colors.white,
													),
												),
												const SizedBox(height: 10),
												Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: options.map((option) => Padding(
														padding: const EdgeInsets.symmetric(horizontal: 8),
														child: ChoiceChip(
															label: Text(option),
															selected: answers[idx] == option,
															onSelected: (_) {
																setState(() {
																	answers[idx] = option;
																});
															},
															selectedColor: Colors.white,
															backgroundColor: answers[idx] == option ? Colors.white : Color(0xFFFFB7CD),
															labelStyle: TextStyle(color: answers[idx] == option ? Color(0xFF633B48) : Color(0xFF633B48)),
															side: BorderSide(color: answers[idx] == option ? Color(0xFF633B48) : Color(0xFF633B48).withOpacity(0.7)),
															checkmarkColor: Color(0xFF633B48),
														),
													)).toList(),
												),
											],
										);
									},
								),
							),
							const SizedBox(height: 20),
							Center(
								child: SizedBox(
									width: 120,
									height: 40,
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
											'SAVE',
											style: TextStyle(
												fontFamily: 'Roboto',
												fontWeight: FontWeight.w400,
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
		);
	}
}
