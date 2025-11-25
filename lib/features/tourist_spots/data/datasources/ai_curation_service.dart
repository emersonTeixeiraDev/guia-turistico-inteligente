import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/util/constants.dart';
import '../models/tourist_spot_model.dart';

class AICurationService {
  late final GenerativeModel _model;

  AICurationService() {
    // MUDANÇA 1: Usamos a versão 2.0 fixa (mais estável que a 'latest')
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: kGeminiApiKey);
  }

  Future<List<TouristSpotModel>> curateList(
    List<TouristSpotModel> rawSpots,
  ) async {
    if (rawSpots.isEmpty) return [];

    final limitedSpots = rawSpots.length > 30
        ? rawSpots.sublist(0, 30)
        : rawSpots;

    final List<Map<String, dynamic>> spotsToAnalyze = limitedSpots.map((spot) {
      return {
        'id': spot.id,
        'name': spot.name,
        'original_category': spot.description,
      };
    }).toList();

    final String spotsJson = jsonEncode(spotsToAnalyze);

    final prompt =
        '''
    Atue como um Guia Turístico Especialista. Analise a lista de locais abaixo.
    
    Regras:
    1. Rating: Nota de 1.0 a 5.0 (seja crítico, só dê 5.0 para atrações mundiais).
    2. Descrição: Resumo curto e vendedor (máx 2 frases) em Português.
    3. Categoria: Use APENAS: "História", "Natureza", "Arte", "Lazer", "Religião" ou "Outros".
    4. Relevância: Marque "is_relevant": false para estacionamentos, hotéis, bancos ou locais sem interesse turístico.

    Entrada:
    $spotsJson

    Saída (JSON Schema):
    [
      {
        "id": "string",
        "rating": double,
        "description": "string",
        "category": "string",
        "is_relevant": boolean
      }
    ]
    Retorne APENAS o JSON válido.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final String? responseText = response.text;
      if (responseText == null) return rawSpots;

      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> aiResults = jsonDecode(cleanJson);

      final List<TouristSpotModel> curatedList = [];

      // Cruzamento de dados
      for (var originalSpot in limitedSpots) {
        final aiData = aiResults.firstWhere(
          (element) => element['id'] == originalSpot.id,
          orElse: () => null,
        );

        if (aiData != null) {
          if (aiData['is_relevant'] == true) {
            curatedList.add(
              originalSpot.copyWith(
                description: aiData['description'],
                rating: (aiData['rating'] as num).toDouble(),
              ),
            );
          }
        } else {
          curatedList.add(originalSpot);
        }
      }

      return curatedList;
    } catch (e) {
      return limitedSpots;
    }
  }
}
