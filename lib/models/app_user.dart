/// Represents the current user state in FristFix.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
