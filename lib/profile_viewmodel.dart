import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  StreamSubscription<UserModel?>? _subscription;

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  // Starts listening to the user's profile. Updates arrive automatically.
  void loadProfile(String uid) {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.watchProfile(uid).listen(
      (profile) {
        user = profile;
        errorMessage = profile == null ? 'User profile not found.' : null;
        isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Unable to load profile.';
        isLoading = false;
        notifyListeners();
      },
    );
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}