import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_bloc.dart';

import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource_impl.dart';
import 'features/tourist_spots/data/repositories/tourist_spot_repository_impl.dart';
import 'features/tourist_spots/domain/repositories/tourist_spot_repository.dart';
import 'features/tourist_spots/domain/usecases/get_nearby_spots.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Tourist Spots
  // Usamos registerFactory para criar uma nova instância sempre que a tela pedir.
  // Isso evita problemas de estado "preso" quando você sai e volta para a tela.
  sl.registerLazySingleton(() => TouristSpotBloc(getNearbySpots: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetNearbySpots(sl()));

  // Repository
  sl.registerLazySingleton<TouristSpotRepository>(
    () => TouristSpotRepositoryImpl(remoteDataSource: sl()),
  );
  // Data sources
  sl.registerLazySingleton<TouristSpotRemoteDataSource>(
    () => TouristSpotRemoteDataSourceImpl(client: sl()),
  );
  // ! External
  sl.registerLazySingleton(() => Dio());
}
