import 'package:flutter_test/flutter_test.dart';
import 'package:lena_plant_guide/data/plant_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('локальная база загружает 47 растений с уникальными ID', () async {
    final plants = await PlantRepository.instance.getAll();
    expect(plants.length, 47);
    expect(plants.map((p) => p.id).toSet().length, 47);
    expect(plants.where((p) => p.isRedBookCandidate).length, 21);
    expect(plants.where((p) => !p.isRedBookCandidate).length, 26);
  });
}
