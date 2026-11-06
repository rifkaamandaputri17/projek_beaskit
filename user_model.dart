class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String verificationStatus;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.verificationStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'verification_status': verificationStatus,
      'created_at': createdAt,
    };
  }
}
