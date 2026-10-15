import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plant.dart';

class PlantRepository {
  PlantRepository._();
  static final PlantRepository instance = PlantRepository._();
  List<Plant>? _cache;

  Future<List<Plant>> getAll() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    final raw = await rootBundle.loadString('assets/data/plants.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Файл plants.json должен содержать список растений.');
    }
    final loaded = decoded
        .whereType<Map>()
        .map((item) => Plant.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final ids = loaded.map((plant) => plant.id).toSet();
    if (loaded.length != 47) {
      throw FormatException('Ожидалось 47 растений, найдено: ${loaded.length}.');
    }
    if (ids.length != loaded.length) {
      throw const FormatException('В plants.json обнаружены повторяющиеся ID.');
    }
    _cache = loaded;
    return List.unmodifiable(loaded);
  }
}
