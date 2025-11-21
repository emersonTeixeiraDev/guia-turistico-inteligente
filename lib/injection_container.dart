import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'features/tourist_spots/data/datasources/tourist_spot_remote_datasource_impl.dart';
import 'features/tourist_spots/data/repositories/tourist_spot_repository_impl.dart';
import 'features/tourist_spots/domain/repositories/tourist_spot_repository.dart';
import 'features/tourist_spots/domain/usecases/get_nearby_spots.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => GetNearbySpots(sl()));

  sl.registerLazySingleton<TouristSpotRepository>(
    () => TouristSpotRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TouristSpotRemoteDataSource>(
    () => TouristSpotRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton(() => Dio());
}
