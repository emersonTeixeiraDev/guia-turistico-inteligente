import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🔑 Import NECESSÁRIO para o .env
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/tourist_spot_model.dart';

class AICurationService {
  late final GenerativeModel _model;

  AICurationService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey, //
    );
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
    1. Rating: Nota de 1.0 a 5.0 baseada na qualidade e importância PARA A CIDADE LOCAL.
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

    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        attempts++;

        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);

        final String? responseText = response.text;
        if (responseText == null) throw Exception('Resposta vazia da IA');

        final cleanJson = responseText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final List<dynamic> aiResults = jsonDecode(cleanJson);

        final List<TouristSpotModel> curatedList = [];

        for (var originalSpot in limitedSpots) {
          final aiData = aiResults.firstWhere(
            (element) => element['id'] == originalSpot.id,
            orElse: () => null,
          );

          if (aiData != null) {
            final double rating = (aiData['rating'] as num).toDouble();
            final bool isRelevant = aiData['is_relevant'] == true;

            if (isRelevant && rating >= 4.0) {
              curatedList.add(
                originalSpot.copyWith(
                  description: aiData['description'],
                  rating: rating,
                ),
              );
            }
          }
        }

        // Se chegou aqui, deu sucesso!
        return curatedList;
      } catch (e) {
        print('⚠️ Erro na tentativa $attempts: $e');

        if (attempts >= maxAttempts) {
          print(
            '❌ Gemini falhou após $maxAttempts tentativas. Retornando dados brutos.',
          );
          return limitedSpots;
        }

        // Espera um pouco antes de tentar de novo
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    return limitedSpots; // Fallback final
  }
}
