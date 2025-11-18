import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';

class TouristSpotModel extends TouristSpot {
  const TouristSpotModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.distance,
  });

  factory TouristSpotModel.fromJson(Map<String, dynamic> json) {
    return TouristSpotModel(
      id: json['xid'] ?? '',
      name: json['name'] ?? 'Sem nome',
      description:
          json['wikipedia_extracts']?['text'] ??
          '', // Exemplo de estrutura complexa
      imageUrl: json['preview']?['source'] ?? '',
      latitude: (json['point']?['lat'] ?? 0.0).toDouble(),
      longitude: (json['point']?['lon'] ?? 0.0).toDouble(),
      distance: (json['dist'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xid': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'point': {'lat': latitude, 'lon': longitude},
      'dist': distance,
    };
  }
}
