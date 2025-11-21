import 'package:dio/dio.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import '../../../../core/util/constants.dart';
import '../models/tourist_spot_model.dart';
import 'tourist_spot_remote_datasource.dart';

class TouristSpotRemoteDataSourceImpl implements TouristSpotRemoteDataSource {
  final Dio client;

  TouristSpotRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TouristSpotModel>> getNearbySpots(double lat, double lng) async {
    // URL final: https://api.opentripmap.com/.../radius?radius=1000&lon=...&lat=...
    // Nota: O OpenTripMap pede 'lon' e 'lat' e a chave 'apikey'

    final response = await client.get(
      kRadiusEndpoint,
      queryParameters: {
        'radius': 1000, // 1km de raio (fixo por enquanto)
        'lon': lng,
        'lat': lat,
        'rate': 2, // Apenas lugares com alguma relevância (2+)
        'format': 'json',
        'apikey': kApiKey,
      },
    );

    if (response.statusCode == 200) {
      // A API retorna uma List<dynamic> no formato JSON
      final List<dynamic> jsonList = response.data;

      // Converte cada item da lista (Map) para um TouristSpotModel
      return jsonList
          .map((jsonItem) => TouristSpotModel.fromJson(jsonItem))
          .toList();
    } else {
      // Se der erro 404, 500, etc, lançamos nossa Exception customizada
      throw ServerFailure();
    }
  }
}
