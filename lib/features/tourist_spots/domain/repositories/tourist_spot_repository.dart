import 'package:dartz/dartz.dart';
import 'package:guia_turistico_inteligente/core/error/failures.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';

abstract class TouristSpotRepository {
  Future<Either<Failure, List<TouristSpot>>> getNearbySpots({
    required double lat,
    required double lng,
  });
}
