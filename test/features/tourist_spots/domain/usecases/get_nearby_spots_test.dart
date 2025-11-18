import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/repositories/tourist_spot_repository.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'package:mocktail/mocktail.dart';

// O Mocktail vai fingir ser a classe real para controlar o seu comportamento
class MockTouristSpotRepository extends Mock implements TouristSpotRepository {}

void main() {
  late GetNearbySpots usecase;
  late MockTouristSpotRepository mockTouristSpotRepository;

  // 2. setUp: Executa antes de CADA teste individual
  setUp(() {
    mockTouristSpotRepository = MockTouristSpotRepository();
    usecase = GetNearbySpots(mockTouristSpotRepository);
  });

  // Dados "fakes" para usar no teste
  final tTouristSpots = [
    const TouristSpot(
      id: '1',
      name: 'Torre de Belém',
      description: 'Monumento histórico',
      imageUrl: 'https://exemplo.com/foto.jpg',
      latitude: 38.69,
      longitude: -9.20,
      distance: 150.0,
    ),
  ];

  const tParams = Params(lat: 38.69, lng: -9.20);

  // 3. O Teste em si
  test('deve obter uma lista de locais turísticos do repositório', () async {
    // ARRANGE (Preparação)
    // Ensinamos o Mock: "Quando te chamarem com qualquer lat/lng, responde com SUCESSO (Right) e a lista tTouristSpots"
    when(
      () => mockTouristSpotRepository.getNearbySpots(
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
      ),
    ).thenAnswer((_) async => Right(tTouristSpots));

    // ACT (Ação)
    // Executamos a funcionalidade real
    final result = await usecase(tParams);

    // ASSERT (Verificação)
    // 1. O resultado foi o esperado?
    expect(result, Right(tTouristSpots));

    // 2. O repositório foi realmente chamado com os parâmetros certos?
    verify(
      () => mockTouristSpotRepository.getNearbySpots(
        lat: tParams.lat,
        lng: tParams.lng,
      ),
    );

    // 3. Garante que nada mais foi chamado no repositório
    verifyNoMoreInteractions(mockTouristSpotRepository);
  });
}
