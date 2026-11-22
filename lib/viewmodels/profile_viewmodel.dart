
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile(String uid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _service.getProfile(uid);

      if (user == null) {
        errorMessage = 'User profile not found.';
      }
    } catch (e) {
      errorMessage = 'Unable to load profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String contact,
  }) async {
    if (user == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      final updatedUser = UserModel(
        uid: user!.uid,
        name: name,
        email: user!.email,
        contact: contact,
        role: user!.role,
        profileImage: user!.profileImage,
      );

      await _service.updateProfile(updatedUser);
      user = updatedUser;
      return true;
    } catch (e) {
      errorMessage = 'Unable to update profile.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
