import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/models/tourist_spot_model.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/repositories/tourist_spot_repository_impl.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements TouristSpotRemoteDataSource {}

void main() {
  late TouristSpotRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;

  // Dados Fakes para o Teste
  const tLat = 38.69;
  const tLng = -9.20;

  const tTouristSpotModel = TouristSpotModel(
    id: '1',
    name: 'Castelo de São Jorge',
    description: 'Um castelo medieval',
    imageUrl: 'url.jpg',
    latitude: tLat,
    longitude: tLng,
    distance: 1500.0,
  );
  final List<TouristSpotModel> tTouristSpotModelList = [tTouristSpotModel];

  final List<TouristSpot> tTouristSpotEntityList = tTouristSpotModelList;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    repository = TouristSpotRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('getNearbySpots', () {
    void setUpMockRemoteDataSourceSuccess() {
      when(
        () => mockRemoteDataSource.getNearbySpots(tLat, tLng),
      ).thenAnswer((_) async => tTouristSpotModelList);
    }

    test(
      'deve retornar dados remotos quando a chamada for bem sucedida',
      () async {
        setUpMockRemoteDataSourceSuccess();

        final result = await repository.getNearbySpots(lat: tLat, lng: tLng);

        verify(() => mockRemoteDataSource.getNearbySpots(tLat, tLng));

        expect(result, equals(Right(tTouristSpotEntityList)));
      },
    );

    test(
      'deve retornar ServerFailure quando a chamada remota falhar (ServerException)',
      () async {
        when(
          () => mockRemoteDataSource.getNearbySpots(tLat, tLng),
        ).thenThrow(ServerFailure());

        // ACT
        final result = await repository.getNearbySpots(lat: tLat, lng: tLng);

        // ASSERT
        // 1. Verifica se o DataSource Remoto foi chamado
        verify(() => mockRemoteDataSource.getNearbySpots(tLat, tLng));

        expect(result, equals(Left(ServerFailure())));
      },
    );
  });
}
