import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/pages/tourist_spots_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia Turístico Inteligente',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: TouristSpotsPage(),
    );
  }
}
