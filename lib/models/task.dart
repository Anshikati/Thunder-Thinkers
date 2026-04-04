class Task {
  final String id;
  final String needId;
  final String volunteerId;
  final String status;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String title;
  final String location;
  final String category;
  final String urgencyLevel;
  final String skillsNeeded;
  final String reportedBy;
  final int peopleAffected;
  final double distanceKm;

  const Task({
    required this.id,
    required this.needId,
    required this.volunteerId,
    required this.status,
    required this.assignedAt,
    this.completedAt,
    required this.title,
    required this.location,
    required this.category,
    required this.urgencyLevel,
    required this.skillsNeeded,
    required this.reportedBy,
    required this.peopleAffected,
    required this.distanceKm,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        needId: json['needId'] as String,
        volunteerId: json['volunteerId'] as String,
        status: json['status'] as String? ?? 'new',
        assignedAt: DateTime.parse(json['assignedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        title: json['title'] as String,
        location: json['location'] as String,
        category: json['category'] as String,
        urgencyLevel: json['urgencyLevel'] as String? ?? 'Medium',
        skillsNeeded: json['skillsNeeded'] as String? ?? '',
        reportedBy: json['reportedBy'] as String? ?? '',
        peopleAffected: (json['peopleAffected'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'needId': needId,
        'volunteerId': volunteerId,
        'status': status,
        'assignedAt': assignedAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        'title': title,
        'location': location,
        'category': category,
        'urgencyLevel': urgencyLevel,
        'skillsNeeded': skillsNeeded,
        'reportedBy': reportedBy,
        'peopleAffected': peopleAffected,
        'distanceKm': distanceKm,
      };

  Task copyWith({String? status, DateTime? completedAt}) {
    return Task(
      id: id,
      needId: needId,
      volunteerId: volunteerId,
      status: status ?? this.status,
      assignedAt: assignedAt,
      completedAt: completedAt ?? this.completedAt,
      title: title,
      location: location,
      category: category,
      urgencyLevel: urgencyLevel,
      skillsNeeded: skillsNeeded,
      reportedBy: reportedBy,
      peopleAffected: peopleAffected,
      distanceKm: distanceKm,
    );
  }
}
