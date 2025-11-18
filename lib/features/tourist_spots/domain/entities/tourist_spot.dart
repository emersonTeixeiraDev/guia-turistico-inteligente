import 'package:equatable/equatable.dart';

class TouristSpot extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double distance;

  const TouristSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    latitude,
    longitude,
    distance,
  ];
}
