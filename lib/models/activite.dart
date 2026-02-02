class Activite {
  final String titre;
  final String description;
  final String conditions;

  const Activite({
    required this.titre,
    required this.description,
    required this.conditions,
  });

  factory Activite.fromJson(Map<String, dynamic> json) {
    return Activite(
      titre: json['titre'] as String,
      description: json['description'] as String,
      conditions: json['conditions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'conditions': conditions,
    };
  }
}
