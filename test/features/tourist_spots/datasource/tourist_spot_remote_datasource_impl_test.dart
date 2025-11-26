import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guia_turistico_inteligente/core/util/constants.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource_impl.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/models/tourist_spot_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late TouristSpotRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = TouristSpotRemoteDataSourceImpl(client: mockDio);
  });

  const tLat = 10.0;
  const tLng = 20.0;

  // JSON simulado que o Overpass retorna
  final tJson = {
    "elements": [
      {
        "type": "node",
        "id": 123,
        "lat": 10.0,
        "lon": 20.0,
        "tags": {"name": "Local Teste", "tourism": "museum"},
      },
    ],
  };

  group('getNearbySpots', () {
    test(
      'deve retornar uma List<TouristSpotModel> quando a chamada para a API for bem sucedida (200)',
      () async {
        // ARRANGE
        when(
          () => mockDio.get(
            any(), // Aceita qualquer URL
            // 👇 O SEGREDO: Aceita qualquer query complexa que enviarmos
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: tJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: kBaseUrl),
          ),
        );

        // ACT
        final result = await dataSource.getNearbySpots(tLat, tLng);

        // ASSERT
        expect(result, isA<List<TouristSpotModel>>());
        expect(result.length, 1);
        expect(result.first.name, 'Local Teste');

        // Verifica se o Dio foi chamado (sem se preocupar com a string exata da query)
        verify(
          () => mockDio.get(
            kBaseUrl,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).called(1);
      },
    );

    test(
      'deve lançar ServerException quando a chamada para a API falhar (!= 200)',
      () async {
        // ARRANGE
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'Algo deu errado',
            statusCode: 404,
            requestOptions: RequestOptions(path: kBaseUrl),
          ),
        );

        // ACT
        final call = dataSource.getNearbySpots;

        // ASSERT
        expect(() => call(tLat, tLng), throwsA(isA<ServerException>()));
      },
    );

    test(
      'deve lançar ServerException quando o Dio lançar um erro de conexão',
      () async {
        // ARRANGE
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: kBaseUrl),
            type: DioExceptionType.connectionError,
          ),
        );

        // ACT
        final call = dataSource.getNearbySpots;

        // ASSERT
        expect(() => call(tLat, tLng), throwsA(isA<ServerException>()));
      },
    );
  });
}
