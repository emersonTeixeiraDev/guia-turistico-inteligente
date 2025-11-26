import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/util/constants.dart';
import '../models/tourist_spot_model.dart';
import 'tourist_spot_remote_datasource.dart';

class TouristSpotRemoteDataSourceImpl implements TouristSpotRemoteDataSource {
  final Dio client;

  TouristSpotRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TouristSpotModel>> getNearbySpots(
    double lat,
    double lng, {
    double radiusKm = 10,
  }) async {
    try {
      print(
        '🌍 Consultando OSM (Apenas Famosos/Wiki) com Raio de ${radiusKm}km',
      );

      final radiusMeters = (radiusKm * 1000).toInt();

      // 🧠 O FILTRO DA FAMA:
      // Adicionamos ["wikipedia"] ao lado da categoria.
      // Isso diz: "Só me traga 'tourism' SE tiver um link da 'wikipedia' junto".

      final String overpassQuery =
          '''
        [out:json];
        (
          node["tourism"]["wikipedia"](around:$radiusMeters,$lat,$lng);
          node["historic"]["wikipedia"](around:$radiusMeters,$lat,$lng);
          node["religion"~"cathedral|temple"]["wikipedia"](around:$radiusMeters,$lat,$lng);
          node["natural"]["wikipedia"](around:$radiusMeters,$lat,$lng);
          node["leisure"~"park|stadium"]["wikipedia"](around:$radiusMeters,$lat,$lng); // Adicionei Estádios e Parques Grandes
        );
        out;
      ''';

      final response = await client.get(
        kBaseUrl,
        queryParameters: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['elements'] != null && (data['elements'] as List).isNotEmpty) {
          final List<dynamic> elements = data['elements'];

          // Filtro de segurança extra: garante que tem nome
          final validSpots = elements.where(
            (e) => e['tags'] != null && e['tags']['name'] != null,
          );

          print('✅ Encontrados ${validSpots.length} locais FAMOSOS.');

          return validSpots
              .map(
                (e) => TouristSpotModel.fromOverpassJson(e, lat, lng),
              ) // Passando lat/lng user
              .toList();
        } else {
          print('⚠️ Nenhum local famoso encontrado neste raio.');
          return [];
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      print('❌ Erro na conexão com Overpass: $e');
      throw ServerException();
    }
  }
}
