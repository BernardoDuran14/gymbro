class PR {
  final int? id;
  final String exercise;
  final double weight;
  final String date;
  final String userEmail;
  final bool verified;
  final String? notes;
  final String? videoUrl;
  final bool synced;

  PR({
    this.id,
    required this.exercise,
    required this.weight,
    required this.date,
    required this.userEmail,
    this.verified = false,
    this.notes,
    this.videoUrl,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'weight': weight,
      'date': date,
      'userEmail': userEmail,
      'verified': verified ? 1 : 0,
      'notes': notes,
      'videoUrl': videoUrl,
      'synced': synced ? 1 : 0,
    };
  }

  factory PR.fromMap(Map<String, dynamic> map) {
    return PR(
      id: map['id'],
      exercise: map['exercise'],
      weight: map['weight'],
      date: map['date'],
      userEmail: map['userEmail'],
      verified: map['verified'] == 1,
      notes: map['notes'],
      videoUrl: map['videoUrl'],
      synced: map['synced'] == 1,
    );
  }

  PR copyWith({
    int? id,
    String? exercise,
    double? weight,
    String? date,
    String? userEmail,
    bool? verified,
    String? notes,
    String? videoUrl,
    bool? synced,
  }) {
    return PR(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      userEmail: userEmail ?? this.userEmail,
      verified: verified ?? this.verified,
      notes: notes ?? this.notes,
      videoUrl: videoUrl ?? this.videoUrl,
      synced: synced ?? this.synced,
    );
  }
}
