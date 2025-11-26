abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<bool> checkPermission();
  Future<void> requestPermission();
  // Retorna Position? (pode ser null se falhar)
  Future<(double, double)?> getCurrentPosition();
}
