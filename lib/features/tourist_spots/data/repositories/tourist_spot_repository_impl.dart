import 'package:dartz/dartz.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';

import '../../domain/repositories/tourist_spot_repository.dart';

class TouristSpotRepositoryImpl implements TouristSpotRepository {
  final TouristSpotRemoteDataSource remoteDataSource;

  TouristSpotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TouristSpot>>> getNearbySpots({
    required double lat,
    required double lng,
  }) async {
    try {
      final remoteSpots = await remoteDataSource.getNearbySpots(lat, lng);
      return Right(remoteSpots);
    } on ServerFailure {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
