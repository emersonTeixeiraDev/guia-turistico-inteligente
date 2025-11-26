import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/repositories/tourist_spot_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../entities/tourist_spot.dart';

class GetNearbySpots implements UseCases<List<TouristSpot>, Params> {
  final TouristSpotRepository repository;

  GetNearbySpots(this.repository);

  @override
  Future<Either<Failure, List<TouristSpot>>> call(Params params) async {
    return await repository.getNearbySpots(
      lat: params.lat,
      lng: params.lng,
      radiusKm: params.radiusKm,
    );
  }
}

class Params extends Equatable {
  final double lat;
  final double lng;
  final double radiusKm;

  const Params({required this.lat, required this.lng, this.radiusKm = 10});

  @override
  List<Object> get props => [lat, lng, radiusKm];
}
