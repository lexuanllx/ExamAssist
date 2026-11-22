
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String contact;
  final String role;
  final String profileImage;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.contact,
    required this.role,
    this.profileImage = '',
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      contact: data['contact'] ?? '',
      role: data['role'] ?? 'Assistant Invigilator',
      profileImage: data['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'contact': contact,
      'role': role,
      'profileImage': profileImage,
    };
  }
}
