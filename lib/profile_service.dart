import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getProfile(String uid) async {
    final document =
        await _db.collection('users').doc(uid).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return UserModel.fromMap(uid, document.data()!);
  }

  Future<void> updateProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).update({
      'name': user.name,
      'contact': user.contact,
      'profileImage': user.profileImage,
    });
  }

  Stream<UserModel?> watchProfile(String uid) {
  return _db.collection('users').doc(uid).snapshots().map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  });
}
}