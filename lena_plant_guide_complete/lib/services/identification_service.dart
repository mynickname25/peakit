import '../models/plant.dart';

class PlantQuestion {
  const PlantQuestion({required this.key, required this.title, required this.options});
  final String key;
  final String title;
  final List<String> options;
}

class PlantMatch {
  const PlantMatch({required this.plant, required this.score, required this.answeredTraits});
  final Plant plant;
  final int score;
  final int answeredTraits;
  int get percent => answeredTraits == 0 ? 0 : ((score / answeredTraits) * 100).round().clamp(0, 100).toInt();
}

class IdentificationService {
  static const questions = <PlantQuestion>[
    PlantQuestion(key: 'flowerColor', title: 'Какого цвета цветок или соцветие?', options: ['Жёлтый', 'Белый или светлый', 'Розовый или пурпурный', 'Синий или фиолетовый', 'Зелёный или бурый', 'Цветков нет / споры', 'Не знаю']),
    PlantQuestion(key: 'leafShape', title: 'Какие листья по форме?', options: ['Узкие или линейные', 'Широкие или округлые', 'Сильно рассечённые', 'Сложные, из отдельных листочков', 'Чешуйчатые или сильно уменьшенные', 'Другая форма / не видно', 'Не знаю']),
    PlantQuestion(key: 'habitat', title: 'Где растёт растение?', options: ['У воды или на болоте', 'В лесу или в тени деревьев', 'На сухом каменистом склоне', 'На лугу или в степи', 'На открытом солнечном месте', 'Другое место', 'Не знаю']),
    PlantQuestion(key: 'floweringPeriod', title: 'Когда цветёт растение?', options: ['Весной (апрель–май)', 'В начале лета (июнь)', 'Летом (июль–август)', 'В конце лета или осенью', 'Цветков нет / спороношение', 'Не знаю']),
    PlantQuestion(key: 'height', title: 'Какова примерная высота?', options: ['Низкое — до 30 см', 'Среднее — примерно 30–100 см', 'Высокое — выше 1 метра', 'Не знаю']),
    PlantQuestion(key: 'light', title: 'Какое освещение в месте роста?', options: ['Солнечное место', 'Полутень', 'Тень', 'Не знаю']),
    PlantQuestion(key: 'moisture', title: 'Насколько влажное место?', options: ['Сухое', 'Умеренно влажное', 'Очень влажное / вода рядом', 'Не знаю']),
  ];

  List<PlantMatch> rank(List<Plant> plants, Map<String, String> answers) {
    final matches = <PlantMatch>[];
    for (final plant in plants) {
      var score = 0;
      var compared = 0;
      for (final entry in answers.entries) {
        if (entry.value == 'Не знаю') continue;
        final raw = plant.traits[entry.key] ?? '';
        final category = _classify(entry.key, raw);
        if (category == 'unknown') continue;
        compared++;
        if (category == _answerCategory(entry.key, entry.value)) score++;
      }
      matches.add(PlantMatch(plant: plant, score: score, answeredTraits: compared));
    }
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.plant.nameRu.compareTo(b.plant.nameRu);
    });
    return matches;
  }

  String _answerCategory(String key, String answer) {
    if (answer == 'Не знаю') return 'unknown';
    if (key == 'flowerColor') {
      if (answer == 'Жёлтый') return 'yellow';
      if (answer == 'Белый или светлый') return 'white';
      if (answer == 'Розовый или пурпурный') return 'pink';
      if (answer == 'Синий или фиолетовый') return 'blue';
      if (answer == 'Зелёный или бурый') return 'green_brown';
      return 'spores';
    }
    if (key == 'leafShape') {
      if (answer == 'Узкие или линейные') return 'linear';
      if (answer == 'Широкие или округлые') return 'broad';
      if (answer == 'Сильно рассечённые') return 'dissected';
      if (answer == 'Сложные, из отдельных листочков') return 'compound';
      if (answer == 'Чешуйчатые или сильно уменьшенные') return 'reduced';
      return 'other';
    }
    if (key == 'habitat') {
      if (answer == 'У воды или на болоте') return 'wet';
      if (answer == 'В лесу или в тени деревьев') return 'forest';
      if (answer == 'На сухом каменистом склоне') return 'rocky';
      if (answer == 'На лугу или в степи') return 'meadow';
      if (answer == 'На открытом солнечном месте') return 'open';
      return 'other';
    }
    if (key == 'floweringPeriod') {
      if (answer == 'Весной (апрель–май)') return 'spring';
      if (answer == 'В начале лета (июнь)') return 'early_summer';
      if (answer == 'Летом (июль–август)') return 'summer';
      if (answer == 'В конце лета или осенью') return 'late';
      return 'spores';
    }
    if (key == 'height') {
      if (answer == 'Низкое — до 30 см') return 'low';
      if (answer == 'Среднее — примерно 30–100 см') return 'medium';
      if (answer == 'Высокое — выше 1 метра') return 'tall';
    }
    if (key == 'light') {
      if (answer == 'Солнечное место') return 'sun';
      if (answer == 'Полутень') return 'partial';
      if (answer == 'Тень') return 'shade';
    }
    if (key == 'moisture') {
      if (answer == 'Сухое') return 'low';
      if (answer == 'Умеренно влажное') return 'medium';
      if (answer == 'Очень влажное / вода рядом') return 'high';
    }
    return 'unknown';
  }

  String _classify(String key, String raw) {
    final s = raw.toLowerCase().replaceAll('ё', 'е');
    if (s.trim().isEmpty || s.contains('проверить') || s.contains('не уточн')) return 'unknown';
    bool has(List<String> words) => words.any(s.contains);
    switch (key) {
      case 'flowerColor':
        if (has(['цветков нет', 'спороношение', 'споронос'])) return 'spores';
        if (has(['желт', 'жёлт'])) return 'yellow';
        if (has(['бел', 'светл'])) return 'white';
        if (has(['розов', 'пурпур', 'малинов'])) return 'pink';
        if (has(['син', 'голуб', 'фиолет'])) return 'blue';
        if (has(['зелен', 'зелён', 'бур', 'коричнев'])) return 'green_brown';
        return 'unknown';
      case 'leafShape':
        if (has(['редуц', 'чешу', 'влагалищ'])) return 'reduced';
        if (has(['сильно рассеч', 'рассеч', 'перист'])) return 'dissected';
        if (has(['сложн'])) return 'compound';
        if (has(['линейн', 'узк', 'нитевид', 'игловид'])) return 'linear';
        if (has(['широк', 'округл', 'эллипс', 'сердцевид', 'овальн'])) return 'broad';
        if (has(['членист'])) return 'reduced';
        return 'unknown';
      case 'habitat':
        if (has(['болот', 'вод', 'берег', 'мелковод', 'сыр', 'влажн'])) return 'wet';
        if (has(['лес', 'опушк', 'полутен'])) return 'forest';
        if (has(['камен', 'скал', 'осып', 'обрыв'])) return 'rocky';
        if (has(['луг', 'степ', 'лугов'])) return 'meadow';
        if (has(['солн', 'открыт', 'сух'])) return 'open';
        return 'unknown';
      case 'floweringPeriod':
        if (has(['цветков нет', 'спороношение', 'споры'])) return 'spores';
        if (has(['апрель', 'май'])) return 'spring';
        if (has(['июнь'])) return 'early_summer';
        if (has(['июль', 'август'])) return 'summer';
        if (has(['сентябр', 'октябр', 'конец лета', 'осень'])) return 'late';
        return 'unknown';
      case 'height':
        if (has(['1–2,5 м', '1-2,5 м', '1–2 м', '1-2 м', '1,5 м', '2 м'])) return 'tall';
        final nums = RegExp(r'(\d+)').allMatches(s).map((m) => int.tryParse(m.group(0)!) ?? 0).toList();
        if (s.contains('см') && nums.isNotEmpty) {
          final max = nums.reduce((a, b) => a > b ? a : b);
          if (max <= 30) return 'low';
          if (max <= 100) return 'medium';
          return 'tall';
        }
        if (s.contains('м') && !s.contains('см')) return 'tall';
        return 'unknown';
      case 'light':
        if (has(['полутен'])) return 'partial';
        if (has(['тень', 'тенист'])) return 'shade';
        if (has(['солн'])) return 'sun';
        return 'unknown';
      case 'moisture':
        if (has(['высок', 'очень влаж', 'вод'])) return 'high';
        if (has(['низк', 'сух'])) return 'low';
        if (has(['умерен', 'средн'])) return 'medium';
        return 'unknown';
      default:
        return 'unknown';
    }
  }
}
