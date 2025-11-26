import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guia_turistico_inteligente/core/plataform/location_service.dart'; // Corrigi o caminho (plataform -> platform) se necessário
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_event.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_state.dart';

const String serverFailureMessage = 'Erro ao conectar com o servidor';

class TouristSpotBloc extends Bloc<TouristSpotEvent, TouristSpotState> {
  final GetNearbySpots getNearbySpots;
  final LocationService locationService;

  TouristSpotBloc({required this.getNearbySpots, required this.locationService})
    : super(TouristSpotInitial()) {
    // Handler para busca manual (quando passamos lat/lng)
    on<GetNearbySpotsEvent>(_onGetNearbySpots);

    // Handler para busca automática (GPS)
    on<GetSpotsByCurrentLocationEvent>(_onGetByGPS);
  }

  // --- LÓGICA DO GPS ---
  Future<void> _onGetByGPS(
    GetSpotsByCurrentLocationEvent
    event, // <--- CORREÇÃO 1: O tipo do evento correto
    Emitter<TouristSpotState> emit,
  ) async {
    emit(TouristSpotLoading());

    // 1. Verifica se o GPS (Hardware) está ligado
    // CORREÇÃO 2: Usar isLocationServiceEnabled em vez de checkPermission aqui
    final isEnabled = await locationService.isLocationServiceEnabled();
    if (!isEnabled) {
      emit(
        const TouristSpotError(message: 'GPS desligado. Ative para continuar.'),
      );
      return;
    }

    // 2. Verifica Permissões do App
    bool hasPermission = await locationService.checkPermission();
    if (!hasPermission) {
      // Tenta pedir permissão
      await locationService.requestPermission();
      hasPermission = await locationService.checkPermission();

      if (!hasPermission) {
        emit(
          const TouristSpotError(message: 'Permissão de localização negada.'),
        );
        return;
      }
    }

    // 3. Pega a Posição
    final position = await locationService.getCurrentPosition();
    if (position == null) {
      emit(
        const TouristSpotError(
          message: 'Não foi possível obter sua localização.',
        ),
      );
      return;
    }

    // 4. Chama o UseCase (Reaproveitando a lógica de busca)
    final (lat, lng) = position;

    // Aqui chamamos o usecase diretamente
    final failureOrSpots = await getNearbySpots(Params(lat: lat, lng: lng));

    failureOrSpots.fold(
      (failure) => emit(const TouristSpotError(message: serverFailureMessage)),
      (spots) => emit(TouristSpotLoaded(spots: spots)),
    );
  }

  // --- LÓGICA MANUAL ---
  // CORREÇÃO 3: Esta função foi movida para DENTRO da classe
  Future<void> _onGetNearbySpots(
    GetNearbySpotsEvent event,
    Emitter<TouristSpotState> emit,
  ) async {
    emit(TouristSpotLoading());

    final failureOrSpots = await getNearbySpots(
      Params(lat: event.lat, lng: event.lng),
    );

    failureOrSpots.fold(
      (failure) => emit(const TouristSpotError(message: serverFailureMessage)),
      (spots) => emit(TouristSpotLoaded(spots: spots)),
    );
  }
}
