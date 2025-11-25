import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/models/tourist_spot_model.dart';
import '../../../../core/util/constants.dart';

class AICurationService {
  late final GenerativeModel _model;

  AICurationService() {
    // Usamos o 'gemini-1.5-flash' pois é rápido, barato e inteligente
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: kGeminiApiKey);
  }

  Future<List<TouristSpotModel>> curateList(
    List<TouristSpotModel> rawSpots,
  ) async {
    if (rawSpots.isEmpty) return [];
    print('🤖 Gemini: Analisando ${rawSpots.length} locais...');

    final List<Map<String, dynamic>> spotsToAnalyze = rawSpots.map((spot) {
      return {
        'id': spot.id,
        'name': spot.name,
        'original_category': spot.description, // Enviamos o que temos do OSM
      };
    }).toList();

    final String spotsJson = jsonEncode(spotsToAnalyze);

    // 2. O Prompt (A ordem exata para a IA)
    final prompt =
        '''
    Atue como um Guia Turístico Especialista. Tenho uma lista de locais do OpenStreetMap (JSON abaixo).
    Analise cada um e retorne um JSON Array puro com melhorias.

    Regras:
    1. Rating: Nota de 1.0 a 5.0 baseada na relevância turística.
    2. Descrição: Resumo curto e vendedor (máx 2 frases) em Português.
    3. Categoria: Corrija para: "História", "Natureza", "Arte", "Lazer", "Religião" ou "Outros".
    4. Relevância: Se for irrelevante (estacionamento, banheiro, hotel), marque "is_relevant": false.

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
    Retorne APENAS o JSON válido, sem markdown.
    ''';

    try {
      // 3. Envia para o Gemini
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final String? responseText = response.text;
      if (responseText == null) return rawSpots;

      // Limpeza de markdown caso a IA mande ```json
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // 4. Decodifica a resposta
      final List<dynamic> aiResults = jsonDecode(cleanJson);
      final List<TouristSpotModel> curatedList = [];

      for (var originalSpot in rawSpots) {
        // Acha o resultado correspondente da IA pelo ID
        final aiData = aiResults.firstWhere(
          (element) => element['id'] == originalSpot.id,
          orElse: () => null,
        );

        if (aiData != null && aiData['is_relevant'] == true) {
          // 🛑 AQUI VAI DAR ERRO POR ENQUANTO (copyWith não existe ainda)
          curatedList.add(
            originalSpot.copyWith(
              description: aiData['description'],
              // rating: aiData['rating'], // Futuramente adicionaremos rating
            ),
          );
        } else if (aiData == null) {
          // Se a IA ignorou, mantemos o original
          curatedList.add(originalSpot);
        }
      }

      print(
        '✨ Gemini: Curadoria finalizada. De ${rawSpots.length} para ${curatedList.length} locais.',
      );
      return curatedList;
    } catch (e) {
      print('❌ Erro no Gemini: $e');
      return rawSpots; // Fallback: retorna lista original se der erro
    }
  }
}
