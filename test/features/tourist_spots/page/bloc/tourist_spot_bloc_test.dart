import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/core/plataform/location_service.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_event.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_state.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_bloc.dart';

// 1. Mock do UseCase
class MockGetNearbySpots extends Mock implements GetNearbySpots {}

// 2. Mock do LocationService (NOVO)
class MockLocationService extends Mock implements LocationService {}

void main() {
  late TouristSpotBloc bloc;
  late MockGetNearbySpots mockGetNearbySpots;
  late MockLocationService mockLocationService; // <--- Instância do Mock

  setUp(() {
    mockGetNearbySpots = MockGetNearbySpots();
    mockLocationService = MockLocationService(); // <--- Inicializa

    // Cria o BLoC injetando os dois mocks
    bloc = TouristSpotBloc(
      getNearbySpots: mockGetNearbySpots,
      locationService: mockLocationService,
    );
  });

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

  setUpAll(() {
    registerFallbackValue(const Params(lat: 0, lng: 0));
  });

  test('estado inicial deve ser TouristSpotInitial', () {
    expect(bloc.state, equals(TouristSpotInitial()));
  });

  group('GetNearbySpotsEvent (Manual)', () {
    blocTest<TouristSpotBloc, TouristSpotState>(
      'deve emitir [Loading, Loaded] quando os dados forem buscados com sucesso',
      build: () {
        when(
          () => mockGetNearbySpots(any()),
        ).thenAnswer((_) async => Right(tList));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetNearbySpotsEvent(lat: tLat, lng: tLng)),
      expect: () => [TouristSpotLoading(), TouristSpotLoaded(spots: tList)],
    );

    blocTest<TouristSpotBloc, TouristSpotState>(
      'deve emitir [Loading, Error] quando a busca falhar',
      build: () {
        when(
          () => mockGetNearbySpots(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetNearbySpotsEvent(lat: tLat, lng: tLng)),
      expect: () => [
        TouristSpotLoading(),
        // Corrigido o nome da constante (se estiver diferente no seu arquivo bloc, verifique o nome exato lá)
        const TouristSpotError(message: serverFailureMessage),
      ],
    );
  });

  // --- TESTES NOVOS PARA O GPS ---
  group('GetSpotsByCurrentLocationEvent (GPS)', () {
    test('deve emitir erro se o GPS estiver desligado', () async {
      // Arrange
      when(
        () => mockLocationService.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false); // GPS Desligado

      // Act
      bloc.add(GetSpotsByCurrentLocationEvent());

      // Assert
      await expectLater(
        bloc.stream,
        emitsInOrder([
          TouristSpotLoading(),
          const TouristSpotError(
            message: 'GPS desligado. Ative para continuar.',
          ),
        ]),
      );
    });
  });
}
