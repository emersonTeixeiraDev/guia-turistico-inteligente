import '../models/tourist_spot_model.dart';

abstract class TouristSpotRemoteDataSource {
  Future<List<TouristSpotModel>> getNearbySpots(
    double lat,
    double lng, {
    double radiusKm = 10,
  });
}
