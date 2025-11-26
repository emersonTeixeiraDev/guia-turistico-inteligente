import 'package:equatable/equatable.dart';

abstract class TouristSpotEvent extends Equatable {
  const TouristSpotEvent();

  @override
  List<Object> get props => [];
}

class GetNearbySpotsEvent extends TouristSpotEvent {
  final double lat;
  final double lng;

  const GetNearbySpotsEvent({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];
}

class GetSpotsByCurrentLocationEvent extends TouristSpotEvent {
  final double radiusKm;

  const GetSpotsByCurrentLocationEvent({this.radiusKm = 2.0});

  @override
  List<Object> get props => [radiusKm];
}
