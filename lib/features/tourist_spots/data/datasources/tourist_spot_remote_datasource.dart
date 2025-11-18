import '../models/tourist_spot_model.dart';

abstract class TouristSpotRemoteDataSource {
  Future<List<TouristSpotModel>> getgetNearbySpots(double lat, double lng);
}
