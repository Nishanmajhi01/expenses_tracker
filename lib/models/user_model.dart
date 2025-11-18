class AppUser {
  String uid;
  String fullName;
  String email;
  String? profileImageUrl;

  // NEW OPTIONAL FIELDS (do not affect old data)
  double? monthlyBudget;
  String? currency;
  bool? darkModeEnabled;
  DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.profileImageUrl,

    // Newly added
    this.monthlyBudget,
    this.currency,
    this.darkModeEnabled,
    this.createdAt,
  });

  // Convert AppUser object to Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,

      // NEW FIELDS (saved only if not null)
      'monthlyBudget': monthlyBudget,
      'currency': currency,
      'darkModeEnabled': darkModeEnabled,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Convert Map from Firestore to AppUser object
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],

      // NEW FIELDS (safe if missing)
      monthlyBudget: map['monthlyBudget'] != null
          ? (map['monthlyBudget'] as num).toDouble()
          : null,
      currency: map['currency'],
      darkModeEnabled: map['darkModeEnabled'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}