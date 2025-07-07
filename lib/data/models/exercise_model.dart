class Exercise {
  final int? id;
  final int routineId;
  final String name;
  final String setsReps;
  final String restTime;
  final double? weight;
  final String? notes;

  Exercise({
    this.id,
    required this.routineId,
    required this.name,
    required this.setsReps,
    required this.restTime,
    this.weight,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'name': name,
      'setsReps': setsReps,
      'restTime': restTime,
      'weight': weight,
      'notes': notes,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      routineId: map['routineId'],
      name: map['name'],
      setsReps: map['setsReps'],
      restTime: map['restTime'],
      weight: map['weight'],
      notes: map['notes'],
    );
  }

  Exercise copyWith({
    int? id,
    int? routineId,
    String? name,
    String? setsReps,
    String? restTime,
    double? weight,
    String? notes,
  }) {
    return Exercise(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      setsReps: setsReps ?? this.setsReps,
      restTime: restTime ?? this.restTime,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }
}
