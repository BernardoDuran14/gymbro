class Routine {
  final int? id;
  final String name;
  final String level;
  final String description;

  Routine({
    this.id,
    required this.name,
    required this.level,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'level': level, 'description': description};
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      level: map['level'],
      description: map['description'],
    );
  }

  Routine copyWith({
    int? id,
    String? name,
    String? level,
    String? description,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
    );
  }
}
