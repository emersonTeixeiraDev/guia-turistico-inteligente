import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/ai_curation_service.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/models/tourist_spot_model.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/repositories/tourist_spot_repository_impl.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements TouristSpotRemoteDataSource {}

class MockAICurationService extends Mock implements AICurationService {}

void main() {
  late TouristSpotRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockAICurationService mockAICurationService;

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
    rating: 4.5,
  );

  final List<TouristSpotModel> tTouristSpotModelList = [tTouristSpotModel];
  final List<TouristSpot> tTouristSpotEntityList = tTouristSpotModelList;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockAICurationService = MockAICurationService();

    repository = TouristSpotRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      aiCurationService: mockAICurationService,
    );
  });

  group('getNearbySpots', () {
    test(
      'deve retornar dados curados pela IA quando a chamada for bem sucedida',
      () async {
        when(
          () => mockRemoteDataSource.getNearbySpots(any(), any()),
        ).thenAnswer((_) async => tTouristSpotModelList);

        when(
          () => mockAICurationService.curateList(any()),
        ).thenAnswer((_) async => tTouristSpotModelList);

        final result = await repository.getNearbySpots(lat: tLat, lng: tLng);

        // ASSERT
        // Verifica chamada no OSM
        verify(() => mockRemoteDataSource.getNearbySpots(tLat, tLng)).called(1);

        // Verifica chamada na IA
        verify(
          () => mockAICurationService.curateList(tTouristSpotModelList),
        ).called(1);

        expect(result, equals(Right(tTouristSpotEntityList)));
      },
    );

    test(
      'deve retornar ServerFailure quando a chamada remota falhar',
      () async {
        when(
          () => mockRemoteDataSource.getNearbySpots(any(), any()),
        ).thenThrow(ServerException());

        final result = await repository.getNearbySpots(lat: tLat, lng: tLng);

        verify(() => mockRemoteDataSource.getNearbySpots(tLat, tLng)).called(1);

        verifyNever(() => mockAICurationService.curateList(any()));

        expect(result, equals(Left(ServerFailure())));
      },
    );
  });
}
