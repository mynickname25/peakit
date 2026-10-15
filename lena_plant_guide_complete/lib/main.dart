import 'package:flutter/material.dart';
import 'data/plant_repository.dart';
import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlantGuideApp());
}

class PlantGuideApp extends StatelessWidget {
  const PlantGuideApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Флора Ленских столбов',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6B45)), useMaterial3: true),
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatelessWidget {
  const _AppLoader();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PlantRepository.instance.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Не удалось загрузить базу растений.\n${snapshot.error}', textAlign: TextAlign.center))));
        }
        return HomeScreen(plants: snapshot.data!);
      },
    );
  }
}
