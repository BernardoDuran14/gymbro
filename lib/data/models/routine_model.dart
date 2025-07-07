class Routine {
  final int? id;
  final String name;
  final String level;
  final String description;
  final String? userId;

  Routine({
    this.id,
    required this.name,
    required this.level,
    required this.description,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'description': description,
      'userId': userId,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      level: map['level'],
      description: map['description'],
      userId: map['userId'],
    );
  }

  Routine copyWith({
    int? id,
    String? name,
    String? level,
    String? description,
    String? userId,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }
}
