import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Imports do Location Service (Core)
// Verifique se a sua pasta se chama 'platform' ou 'plataform' (no seu código estava plataform)
import 'package:guia_turistico_inteligente/core/plataform/location_service.dart';
import 'package:guia_turistico_inteligente/core/plataform/location_service_impl.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/ai_curation_service.dart';

// Imports da Feature
import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource_impl.dart';
import 'features/tourist_spots/data/repositories/tourist_spot_repository_impl.dart';
import 'features/tourist_spots/domain/repositories/tourist_spot_repository.dart';
import 'features/tourist_spots/domain/usecases/get_nearby_spots.dart';
import 'features/tourist_spots/presentation/bloc/tourist_spot_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Tourist Spots

  // Bloc
  // CORREÇÃO: Usamos registerFactory (e não Singleton) para o BLoC
  sl.registerFactory(
    () => TouristSpotBloc(
      getNearbySpots: sl(),
      locationService: sl(), // Injeta o LocationService
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNearbySpots(sl()));

  // Repository
  sl.registerLazySingleton<TouristSpotRepository>(
    () => TouristSpotRepositoryImpl(
      remoteDataSource: sl(),
      aiCurationService: sl(),
    ),
  );

  sl.registerLazySingleton<AICurationService>(() => AICurationService());

  sl.registerLazySingleton<TouristSpotRemoteDataSource>(
    () => TouristSpotRemoteDataSourceImpl(client: sl()),
  );

  // Registro do LocationService
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());

  // ! External
  sl.registerLazySingleton(() => Dio());
}
