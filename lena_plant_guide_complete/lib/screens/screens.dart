import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/identification_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.plants});
  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Флора Ленских столбов')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Icon(Icons.eco, size: 76, color: Colors.green),
        const SizedBox(height: 12),
        Text('Определи растение', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ответь на несколько вопросов о цветках, листьях и месте произрастания. Приложение работает офлайн.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _HomeButton(icon: Icons.search, label: 'Определить растение', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(plants: plants)))),
        const SizedBox(height: 12),
        _HomeButton(icon: Icons.menu_book, label: 'Каталог растений (${plants.length})', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(plants: plants)))),
        const SizedBox(height: 24),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Важно: определение по признакам предварительное. Статус краснокнижных видов требует проверки по актуальным официальным изданиям. Не срывай редкие растения.'))),
      ]),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(height: 56, child: FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label)));
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.plants});
  final List<Plant> plants;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0;
  final Map<String, String> answers = {};
  @override
  Widget build(BuildContext context) {
    final question = IdentificationService.questions[index];
    return Scaffold(
      appBar: AppBar(title: Text('Вопрос ${index + 1} из ${IdentificationService.questions.length}')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LinearProgressIndicator(value: (index + 1) / IdentificationService.questions.length),
        const SizedBox(height: 24),
        Text(question.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _answer(option),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
          ),
        ),
        TextButton(onPressed: () => _answer('Не знаю'), child: const Text('Пропустить вопрос')),
      ])),
    );
  }
  void _answer(String option) {
    answers[IdentificationService.questions[index].key] = option;
    if (index < IdentificationService.questions.length - 1) {
      setState(() => index++);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(plants: widget.plants, answers: Map.of(answers))));
    }
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.plants, required this.answers});
  final List<Plant> plants;
  final Map<String, String> answers;
  @override
  Widget build(BuildContext context) {
    final matches = IdentificationService().rank(plants, answers);
    final shown = matches.take(8).toList();
    return Scaffold(appBar: AppBar(title: const Text('Возможные совпадения')), body: ListView(padding: const EdgeInsets.all(12), children: [
      const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Это подбор по введённым признакам, а не гарантированное определение. Если признаки не совпадают, попробуй пройти опрос ещё раз.'))),
      ...shown.map((match) => PlantTile(plant: match.plant, subtitle: match.answeredTraits == 0 ? 'Недостаточно данных для оценки' : 'Совпадение по признакам: ${match.percent}%')),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(plants: plants))), icon: const Icon(Icons.refresh), label: const Text('Пройти заново')),
    ]));
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.plants});
  final List<Plant> plants;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}
class _CatalogScreenState extends State<CatalogScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.plants.where((p) => '${p.nameRu} ${p.nameLa} ${p.family}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(appBar: AppBar(title: const Text('Каталог растений')), body: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Поиск по названию или семейству', border: OutlineInputBorder()), onChanged: (value) => setState(() => query = value))),
      Expanded(child: filtered.isEmpty ? const Center(child: Text('Ничего не найдено')) : ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) => PlantTile(plant: filtered[i]))),
    ]));
  }
}

class PlantTile extends StatelessWidget {
  const PlantTile({super.key, required this.plant, this.subtitle});
  final Plant plant;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: ListTile(leading: Icon(plant.isRedBookCandidate ? Icons.park : Icons.local_florist, color: plant.isRedBookCandidate ? Colors.deepOrange : Colors.green), title: Text(plant.nameRu), subtitle: Text(subtitle ?? (plant.nameLa.isEmpty ? plant.family : '${plant.nameLa}\n${plant.family}')), isThreeLine: subtitle == null, trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant)))));
}

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key, required this.plant});
  final Plant plant;
  @override
  Widget build(BuildContext context) {
    const labels = <String, String>{'leafType':'Тип листьев','leafShape':'Форма листьев','leafArrangement':'Расположение листьев','flowerColor':'Цвет цветков/соцветия','floweringPeriod':'Период цветения / спороношения','flowerType':'Тип цветка / соцветия','fruitReproduction':'Тип плода / размножения','height':'Примерная высота','habitat':'Местообитание','moisture':'Потребность во влаге','light':'Освещённость'};
    return Scaffold(appBar: AppBar(title: Text(plant.nameRu)), body: ListView(padding: const EdgeInsets.all(16), children: [
      Icon(plant.isRedBookCandidate ? Icons.park : Icons.local_florist, size: 64, color: Colors.green),
      const SizedBox(height: 8), Text(plant.nameRu, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
      if (plant.nameLa.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(plant.nameLa, style: const TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.center)),
      const SizedBox(height: 16),
      _info('Семейство', plant.family), _info('Жизненная форма', plant.lifeForm), _info('Группа', plant.group),
      _info('Категория базы', plant.isRedBookCandidate ? 'Кандидат в краснокнижные виды — статус необходимо проверить' : 'Обычное растение из предварительной подборки'),
      if (plant.statusNote.isNotEmpty) _info('Примечание к статусу', plant.statusNote),
      if (plant.description.isNotEmpty) _info('Описание / местообитание', plant.description),
      if (plant.parkZone.isNotEmpty) _info('Зона парка', plant.parkZone),
      const Divider(height: 28), Text('Признаки', style: Theme.of(context).textTheme.titleLarge),
      ...labels.entries.map((e) => _info(e.value, plant.trait(e.key))),
      if (plant.source.isNotEmpty) _info('Источник в исходной таблице', plant.source),
      const SizedBox(height: 12), const Text('В исходной таблице часть признаков и охранных статусов отмечена как предварительная. Проверяй эти сведения по научным и официальным источникам.'),
    ]));
  }
  Widget _info(String title, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(value.isEmpty ? 'Нет данных' : value)]));
}
