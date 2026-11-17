
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final contactController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool initialized = false;
  bool isEditing = false;

  // Stores the selected photo locally.
  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    super.dispose();
  }

  // Validate name.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    return null;
  }

  // Validate Malaysian mobile number.
  String? validateMalaysianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your contact number';
    }

    final phoneRegex = RegExp(
      r'^(?:01[0-9]{8,9}|\+?601[0-9]{8,9})$',
    );

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid Malaysian mobile number';
    }

    return null;
  }

  // Select profile photo from gallery.
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select photo.'),
        ),
      );
    }
  }

  // Cancel editing and restore original information.
  void cancelEditing() {
    final vm = context.read<ProfileViewModel>();

    nameController.text = vm.user!.name;
    contactController.text = vm.user!.contact;

    setState(() {
      selectedImage = null;
      isEditing = false;
    });
  }

  // Save profile information to Firestore.
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<ProfileViewModel>().updateProfile(
      name: nameController.text.trim(),
      contact: contactController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully.'
              : context.read<ProfileViewModel>().errorMessage ??
                  'Profile update failed.',
        ),
      ),
    );

    if (success) {
      setState(() {
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your profile.'),
        ),
      );
    }

    final uid = currentUser.uid;

    // Load profile information.
    if (!initialized && !vm.isLoading && vm.user == null) {
      initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProfileViewModel>().loadProfile(uid);
        }
      });
    }

    // Loading screen.
    if (vm.isLoading && vm.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Profile unavailable.
    if (vm.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: Center(
          child: Text(
            vm.errorMessage ?? 'Profile unavailable',
          ),
        ),
      );
    }

    final user = vm.user!;

    // Initialize text fields with profile information.
    if (!isEditing && nameController.text.isEmpty) {
      nameController.text = user.name;
      contactController.text = user.contact;
    }

    // Display selected local image if available.
    final ImageProvider? avatarImage = selectedImage != null
        ? FileImage(selectedImage!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Profile' : 'My Profile',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // =========================
              // PROFILE PHOTO
              // =========================

              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(
                              Icons.person,
                              size: 55,
                            )
                          : null,
                    ),

                    if (isEditing) ...[
                      const SizedBox(height: 10),

                      TextButton.icon(
                        onPressed: vm.isLoading
                            ? null
                            : pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Change Profile Photo'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // FULL NAME
              // =========================

              if (isEditing)
                TextFormField(
                  controller: nameController,
                  validator: validateName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                )
              else
                profileField(
                  'Full Name',
                  user.name,
                  Icons.person,
                ),

              const SizedBox(height: 16),

              // =========================
              // EMAIL (READ ONLY)
              // =========================

              profileField(
                'Email',
                user.email,
                Icons.email,
              ),

              const SizedBox(height: 16),

              // =========================
              // CONTACT NUMBER
              // =========================

              if (isEditing)
                TextFormField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  validator: validateMalaysianPhone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                )
              else
                profileField(
                  'Contact Number',
                  user.contact,
                  Icons.phone,
                ),

              const SizedBox(height: 16),

              // =========================
              // ROLE (READ ONLY)
              // =========================

              profileField(
                'Assigned Role',
                user.role,
                Icons.badge,
              ),

              const SizedBox(height: 30),

              // =========================
              // ACTION BUTTONS
              // =========================

              if (!isEditing)

                // VIEW MODE
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      nameController.text = user.name;
                      contactController.text = user.contact;
                      selectedImage = null;
                      isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                )

              else

                // EDIT MODE
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: vm.isLoading
                            ? null
                            : saveProfile,
                        icon: const Icon(Icons.save),
                        label: vm.isLoading
                            ? const Text('Saving...')
                            : const Text('Save Changes'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: vm.isLoading
                            ? null
                            : cancelEditing,
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable read-only profile information field.
  Widget profileField(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
