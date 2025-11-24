import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/util/constants.dart';
import '../models/tourist_spot_model.dart';
import 'tourist_spot_remote_datasource.dart';

class TouristSpotRemoteDataSourceImpl implements TouristSpotRemoteDataSource {
  final Dio client;

  TouristSpotRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TouristSpotModel>> getNearbySpots(double lat, double lng) async {
    try {
      final String overpassQuery =
          '[out:json];node["tourism"](around:5000,$lat,$lng);out;';

      final response = await client.get(
        kBaseUrl,
        queryParameters: {
          'data': overpassQuery, // A query vai aqui dentro
        },
      );

      if (response.statusCode == 200) {
        // A Overpass retorna: { "elements": [ ... ] }
        final data = response.data;

        if (data['elements'] != null && (data['elements'] as List).isNotEmpty) {
          final List<dynamic> elements = data['elements'];

          // Filtramos apenas os que têm nome para a lista ficar bonita
          final validSpots = elements.where(
            (e) => e['tags'] != null && e['tags']['name'] != null,
          );

          return validSpots
              .map((e) => TouristSpotModel.fromOverpassJson(e))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
