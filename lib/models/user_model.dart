class AppUser {
  String uid;
  String fullName;
  String email;
  String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
  });

  // Convert AppUser object to Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Convert Map from Firestore to AppUser object
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
