import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_event.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_state.dart';
import 'package:mocktail/mocktail.dart';

// Imports do Projeto
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_bloc.dart';

// 1. Mock do UseCase
class MockGetNearbySpots extends Mock implements GetNearbySpots {}

void main() {
  late TouristSpotBloc bloc;
  late MockGetNearbySpots mockGetNearbySpots;

  setUp(() {
    mockGetNearbySpots = MockGetNearbySpots();
    bloc = TouristSpotBloc(getNearbySpots: mockGetNearbySpots);
  });

  // Dados Fakes
  const tLat = 10.0;
  const tLng = 20.0;
  const tTouristSpot = TouristSpot(
    id: '1',
    name: 'Teste',
    description: 'Desc',
    imageUrl: 'img',
    latitude: tLat,
    longitude: tLng,
    distance: 10,
  );
  final tList = [tTouristSpot];

  // Necessário para o mocktail entender o objeto Params
  setUpAll(() {
    registerFallbackValue(const Params(lat: 0, lng: 0));
  });

  test('estado inicial deve ser TouristSpotInitial', () {
    expect(bloc.state, equals(TouristSpotInitial()));
  });

  group('GetNearbySpotsEvent', () {
    // CASO DE SUCESSO
    blocTest<TouristSpotBloc, TouristSpotState>(
      'deve emitir [Loading, Loaded] quando os dados forem buscados com sucesso',
      build: () {
        // Ensinamos o mock a retornar Sucesso (Right)
        when(
          () => mockGetNearbySpots(any()),
        ).thenAnswer((_) async => Right(tList));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetNearbySpotsEvent(lat: tLat, lng: tLng)),
      expect: () => [TouristSpotLoading(), TouristSpotLoaded(spots: tList)],
    );

    // CASO DE ERRO
    blocTest<TouristSpotBloc, TouristSpotState>(
      'deve emitir [Loading, Error] quando a busca falhar',
      build: () {
        // Ensinamos o mock a retornar Falha (Left)
        when(
          () => mockGetNearbySpots(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetNearbySpotsEvent(lat: tLat, lng: tLng)),
      expect: () => [
        TouristSpotLoading(),
        const TouristSpotError(message: serverFailureMassege),
      ],
    );
  });
}
