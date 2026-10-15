class Plant {
  const Plant({
    required this.id,
    required this.nameRu,
    required this.nameLa,
    required this.group,
    required this.category,
    required this.statusNote,
    required this.parkZone,
    required this.description,
    required this.source,
    required this.family,
    required this.lifeForm,
    required this.traits,
    this.image,
  });

  final String id;
   final String nameRu;
  final String nameLa;
    final String group;
  final String category;
  final String statusNote;
  final String parkZone;
  final String description;
   final String source;
  final String family;
  final String lifeForm;
  final Map<String, String> traits;
  final String? image;

  bool get isRedBookCandidate => category == 'red_book_candidate';

  factory Plant.fromJson(Map<String, dynamic> json) {
  final rawTraits = json['traits'];
  final traits = <String, String>{};
    if (rawTraits is Map) {
      for (final entry in rawTraits.entries) {
        traits[entry.key.toString()] = (entry.value ?? '').toString();
      }
    }
  final rawImage = json['image']?.toString();
  return Plant(
      id: (json['id'] ?? '').toString(),
   nameRu: (json['nameRu'] ?? 'Без названия').toString(),
      nameLa: (json['nameLa'] ?? '').toString(),
      group: (json['group'] ?? '').toString(),
      category: (json['category'] ?? 'ordinary_candidate').toString(),
      statusNote: (json['statusNote'] ?? '').toString(),
      parkZone: (json['parkZone'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),




      
      family: (json['family'] ?? '').toString(),

      lifeForm: (json['lifeForm'] ?? '').toString(),


      traits: traits,
      image: rawImage == null || rawImage.isEmpty || rawImage == 'null' ? null : rawImage,
    );
  }

  String trait(String key) {
    final value = traits[key]?.trim() ?? '';
    return value.isEmpty ? 'Нет данных' : value;
  }
}
