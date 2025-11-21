import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/core/util/constants.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource_impl.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/models/tourist_spot_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late TouristSpotRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = TouristSpotRemoteDataSourceImpl(client: mockDio);
  });

  final tJsonList = [
    {
      "xid": "1",
      "name": "Local Teste",
      "wikipedia_extracts": {"text": "Descricao"},
      "preview": {"source": "url.jpg"},
      "point": {"lat": 10.0, "lon": 20.0},
      "dist": 100.0,
    },
  ];

  void setUpMockDioSuccess200() {
    when(
      () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenAnswer(
      (_) async => Response(
        data: tJsonList,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  }

  void setUpMockDioFailure404() {
    when(
      () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenAnswer(
      (_) async => Response(
        data: 'Algo deu errado',
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  }

  group('getNearbySpots', () {
    const tLat = 10.0;
    const tLng = 20.0;

    test(
      'deve retornar uma List<TouristSpotModel> quando o status code for 200 (Sucesso)',
      () async {
        // ARRANGE
        setUpMockDioSuccess200();

        // ACT
        final result = await dataSource.getNearbySpots(tLat, tLng);

        // ASSERT
        expect(result, isA<List<TouristSpotModel>>());
        // Verifica se chamou a URL certa com a API Key correta
        verify(
          () => mockDio.get(
            kRadiusEndpoint,
            queryParameters: {
              'radius': 1000,
              'lon': tLng,
              'lat': tLat,
              'rate': 2,
              'format': 'json',
              'apikey': kApiKey,
            },
          ),
        );
      },
    );

    test(
      'deve lançar ServerException quando o status code for 404 ou outros erros',
      () async {
        // ARRANGE
        setUpMockDioFailure404();

        // Como esperamos uma Exception, a chamada é feita dentro de uma função anônima
        final call = dataSource.getNearbySpots;

        // Esperamos que a chamada com esses parâmetros jogue a Exception
        expect(() => call(tLat, tLng), throwsA(isA<ServerException>()));
      },
    );
  });
}
