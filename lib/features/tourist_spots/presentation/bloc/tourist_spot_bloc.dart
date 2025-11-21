import 'package:guia_turistico_inteligente/features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_event.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_state.dart';

const String serverFailureMassege = 'Erro ao conectar com o servidor';

class TouristSpotBloc extends Bloc<TouristSpotEvent, TouristSpotState> {
  final GetNearbySpots getNearbySpots;

  TouristSpotBloc({required this.getNearbySpots})
    : super(TouristSpotInitial()) {
    // Registramos o que fazer quando o evento GetNearbySpotsEvent chegar
    on<GetNearbySpotsEvent>(_onGetNearbySpots);
  }

  Future<void> _onGetNearbySpots(
    GetNearbySpotsEvent event,
    Emitter<TouristSpotState> emit,
  ) async {
    // 1. Emite estado de Carregando
    emit(TouristSpotLoading());

    // 2. Chama o UseCase com os parâmetros do evento
    final failureOrSpots = await getNearbySpots(
      Params(lat: event.lat, lng: event.lng),
    );

    // 3. Verifica o resultado (Either)
    // fold(função_se_erro, função_se_sucesso)
    failureOrSpots.fold(
      (failure) => emit(const TouristSpotError(message: serverFailureMassege)),
      (spots) => emit(TouristSpotLoaded(spots: spots)),
    );
  }
}
