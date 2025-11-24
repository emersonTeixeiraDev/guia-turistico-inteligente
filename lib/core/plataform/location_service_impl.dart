import 'package:geolocator/geolocator.dart';
import 'package:guia_turistico_inteligente/core/plataform/location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<void> requestPermission() async {
    await Geolocator.requestPermission();
  }

  @override
  Future<(double, double)?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return (position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }
}
