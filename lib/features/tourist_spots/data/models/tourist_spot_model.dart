import 'package:geolocator/geolocator.dart';
import '../../domain/entities/tourist_spot.dart';

class TouristSpotModel extends TouristSpot {
  const TouristSpotModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.distance,
    super.rating,
  });

  factory TouristSpotModel.fromOverpassJson(
    Map<String, dynamic> json,
    double userLat,
    double userLng,
  ) {
    final tags = json['tags'] ?? {};

    // Categorização
    String category = 'tourist_attraction';
    String displayType = 'Ponto Turístico';

    if (tags.containsKey('tourism')) {
      category = tags['tourism'];
      displayType = 'Turismo (${tags['tourism']})';
    } else if (tags.containsKey('historic')) {
      category = 'historical_site';
      displayType = 'Histórico (${tags['historic']})';
    } else if (tags.containsKey('natural')) {
      category = tags['natural'];
      displayType = 'Natureza (${tags['natural']})';
    } else if (tags.containsKey('religion')) {
      category = 'cathedral';
      displayType = 'Religioso (${tags['religion']})';
    } else if (tags.containsKey('leisure')) {
      category = tags['leisure'];
      displayType = 'Lazer (${tags['leisure']})';
    }

    category = category.replaceAll('_', ' ');

    // Coordenadas do Ponto
    final double spotLat = (json['lat'] ?? 0.0).toDouble();
    final double spotLon = (json['lon'] ?? 0.0).toDouble();

    final double calculatedDistance = Geolocator.distanceBetween(
      userLat,
      userLng,
      spotLat,
      spotLon,
    );

    return TouristSpotModel(
      id: json['id'].toString(),
      name: tags['name'] ?? 'Local Interessante',
      description: displayType,
      imageUrl:
          'https://loremflickr.com/400/400/$category?random=${json['id']}',
      latitude: spotLat,
      longitude: spotLon,
      distance: calculatedDistance, // Distância calculada
      rating: 0.0,
    );
  }

  TouristSpotModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
  }) {
    return TouristSpotModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude,
      longitude: longitude,
      distance: distance,
      rating: rating ?? this.rating,
    );
  }
}
