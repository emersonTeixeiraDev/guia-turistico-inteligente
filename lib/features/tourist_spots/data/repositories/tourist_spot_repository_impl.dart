import 'package:dartz/dartz.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/ai_curation_service.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/data/datasources/tourist_spot_remote_datasource.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';

import '../../domain/repositories/tourist_spot_repository.dart';

class TouristSpotRepositoryImpl implements TouristSpotRepository {
  final TouristSpotRemoteDataSource remoteDataSource;
  final AICurationService aiCurationService;

  TouristSpotRepositoryImpl({
    required this.remoteDataSource,
    required this.aiCurationService,
  });

  @override
  Future<Either<Failure, List<TouristSpot>>> getNearbySpots({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    try {
      final rawSpots = await remoteDataSource.getNearbySpots(
        lat,
        lng,
        radiusKm: radiusKm,
      );
      final curatedSpots = await aiCurationService.curateList(rawSpots);

      return Right(curatedSpots);
    } on ServerFailure {
      return Left(ServerFailure());
    } catch (e) {
      //print('Erro genérico no repo: $e');
      return Left(ServerFailure());
    }
  }
}
