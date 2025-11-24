import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

// Imports do projeto
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

  // 1. JSON simulando a estrutura da Overpass API (OSM)
  final tJsonOverpass = {
    "elements": [
      {
        "type": "node",
        "id": 12345,
        "lat": 10.0,
        "lon": 20.0,
        "tags": {"name": "Museu de Teste", "tourism": "museum"},
      },
    ],
  };

  const tLat = 10.0;
  const tLng = 20.0;

  void setUpMockDioSuccess200() {
    when(
      () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenAnswer(
      (_) async => Response(
        data: tJsonOverpass, // Retorna o JSON novo
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  }

  void setUpMockDioFailure() {
    when(
      () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Erro de conexão',
        type: DioExceptionType.connectionError,
      ),
    );
  }

  group('getNearbySpots', () {
    test(
      'deve retornar uma List<TouristSpotModel> quando a chamada para a API for bem sucedida (200)',
      () async {
        // ARRANGE
        setUpMockDioSuccess200();

        // ACT
        final result = await dataSource.getNearbySpots(tLat, tLng);

        // ASSERT
        expect(result, isA<List<TouristSpotModel>>());
        expect(result.length, 1);
        expect(result.first.name, 'Museu de Teste');

        // Verifica se chamou a URL base correta com a Query da Overpass
        verify(
          () => mockDio.get(
            kBaseUrl, // <--- Usando a constante correta agora
            queryParameters: {
              'data':
                  '[out:json];node["tourism"](around:5000,$tLat,$tLng);out;',
            },
          ),
        );
      },
    );

    test('deve lançar ServerException quando ocorrer um erro no Dio', () async {
      // ARRANGE
      setUpMockDioFailure();

      // ACT
      final call = dataSource.getNearbySpots;

      // ASSERT
      expect(() => call(tLat, tLng), throwsA(isA<ServerException>()));
    });
  });
}
