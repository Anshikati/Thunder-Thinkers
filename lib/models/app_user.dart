enum UserRole { ngoAdmin, fieldWorker, volunteer }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? orgId;
  final String? orgName;
  final String? location;
  final List<String>? skills;
  final int? memberCount;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.orgId,
    this.orgName,
    this.location,
    this.skills,
    this.memberCount,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        role: _roleFromString(json['role'] as String? ?? 'volunteer'),
        orgId: json['orgId'] as String?,
        orgName: json['orgName'] as String?,
        location: json['location'] as String?,
        skills: json['skills'] != null
            ? List<String>.from(json['skills'] as List)
            : null,
        memberCount: (json['memberCount'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        if (orgId != null) 'orgId': orgId,
        if (orgName != null) 'orgName': orgName,
        if (location != null) 'location': location,
        if (skills != null) 'skills': skills,
        if (memberCount != null) 'memberCount': memberCount,
      };

  static UserRole _roleFromString(String s) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == s.toLowerCase(),
      orElse: () => UserRole.volunteer,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.ngoAdmin: return 'NGO Admin';
      case UserRole.fieldWorker: return 'Field Worker';
      case UserRole.volunteer: return 'Volunteer';
    }
  }
}
