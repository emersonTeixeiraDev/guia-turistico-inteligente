import 'package:equatable/equatable.dart';

class TouristSpot extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double distance;
  final double rating;

  const TouristSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.rating = 0.0,
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
    rating,
  ];
}
