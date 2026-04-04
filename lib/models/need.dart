enum UrgencyLevel { low, medium, critical }
enum NeedStatus { reported, assigned, inProgress, completed }
enum NeedCategory { food, medical, shelter, education, sanitation, other }

class Need {
  final String id;
  final NeedCategory category;
  final String description;
  final double urgencyScore;
  final UrgencyLevel urgencyLevel;
  final NeedStatus status;
  final String location;
  final String submittedBy;
  final DateTime timestamp;
  final int peopleAffected;
  final String? assignedVolunteerId;

  const Need({
    required this.id,
    required this.category,
    required this.description,
    required this.urgencyScore,
    required this.urgencyLevel,
    required this.status,
    required this.location,
    required this.submittedBy,
    required this.timestamp,
    required this.peopleAffected,
    this.assignedVolunteerId,
  });


  factory Need.fromJson(Map<String, dynamic> json) => Need(
        id: json['id'] as String,
        category: _categoryFromString(json['category'] as String? ?? 'other'),
        description: json['description'] as String,
        urgencyScore: (json['urgencyScore'] as num?)?.toDouble() ?? 5.0,
        urgencyLevel: _urgencyFromString(json['urgencyLevel'] as String? ?? 'medium'),
        status: _statusFromString(json['status'] as String? ?? 'reported'),
        location: json['location'] as String,
        submittedBy: json['submittedBy'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        peopleAffected: (json['peopleAffected'] as num?)?.toInt() ?? 0,
        assignedVolunteerId: json['assignedVolunteerId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'description': description,
        'urgencyScore': urgencyScore,
        'urgencyLevel': urgencyLevel.name,
        'status': status.name,
        'location': location,
        'submittedBy': submittedBy,
        'timestamp': timestamp.toIso8601String(),
        'peopleAffected': peopleAffected,
        if (assignedVolunteerId != null) 'assignedVolunteerId': assignedVolunteerId,
      };

  static NeedCategory _categoryFromString(String s) {
    return NeedCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == s.toLowerCase(),
      orElse: () => NeedCategory.other,
    );
  }

  static UrgencyLevel _urgencyFromString(String s) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == s.toLowerCase(),
      orElse: () => UrgencyLevel.medium,
    );
  }

  static NeedStatus _statusFromString(String s) {
    return NeedStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == s.toLowerCase(),
      orElse: () => NeedStatus.reported,
    );
  }

  Need copyWith({
    NeedStatus? status,
    String? assignedVolunteerId,
  }) {
    return Need(
      id: id,
      category: category,
      description: description,
      urgencyScore: urgencyScore,
      urgencyLevel: urgencyLevel,
      status: status ?? this.status,
      location: location,
      submittedBy: submittedBy,
      timestamp: timestamp,
      peopleAffected: peopleAffected,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
    );
  }

  String get categoryLabel {
    switch (category) {
      case NeedCategory.food: return 'Food';
      case NeedCategory.medical: return 'Medical';
      case NeedCategory.shelter: return 'Shelter';
      case NeedCategory.education: return 'Education';
      case NeedCategory.sanitation: return 'Sanitation';
      case NeedCategory.other: return 'Other';
    }
  }

  String get urgencyLabel {
    switch (urgencyLevel) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.critical: return 'Critical';
    }
  }

  String get statusLabel {
    switch (status) {
      case NeedStatus.reported: return 'Reported';
      case NeedStatus.assigned: return 'Assigned';
      case NeedStatus.inProgress: return 'In Progress';
      case NeedStatus.completed: return 'Completed';
    }
  }
}
