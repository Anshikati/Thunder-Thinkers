class Volunteer {
  final String id;
  final String name;
  final List<String> skills;
  final String availability;
  final String location;
  final int tasksCompleted;
  final bool isAvailable;
  final String? currentTaskId;
  final int hoursVolunteered;
  final int impactScore;

  const Volunteer({
    required this.id,
    required this.name,
    required this.skills,
    required this.availability,
    required this.location,
    required this.tasksCompleted,
    required this.isAvailable,
    this.currentTaskId,
    this.hoursVolunteered = 0,
    this.impactScore = 0,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) => Volunteer(
        id: json['id'] as String,
        name: json['name'] as String,
        skills: List<String>.from(json['skills'] as List? ?? []),
        availability: json['availability'] as String? ?? 'Flexible',
        location: json['location'] as String? ?? '',
        tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
        isAvailable: json['isAvailable'] as bool? ?? true,
        currentTaskId: json['currentTaskId'] as String?,
        hoursVolunteered: (json['hoursVolunteered'] as num?)?.toInt() ?? 0,
        impactScore: (json['impactScore'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'skills': skills,
        'availability': availability,
        'location': location,
        'tasksCompleted': tasksCompleted,
        'isAvailable': isAvailable,
        if (currentTaskId != null) 'currentTaskId': currentTaskId,
        'hoursVolunteered': hoursVolunteered,
        'impactScore': impactScore,
      };
}
